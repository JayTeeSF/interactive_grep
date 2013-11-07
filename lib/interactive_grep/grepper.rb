require 'zlib'

module InteractiveGrep
  class Grepper
    DEFAULT_PATTERN = %r{.}.freeze
    DEFAULT_PROGRESS_INDICATOR_COUNT = 100.freeze # in verbose mode, show signs of life after processing every N lines
    DEBUG = false.freeze

    attr_reader :file_names, :current_pattern, :file_index
    attr_accessor :progress_indicator_count, :initial_pattern

    def initialize( options = nil )
      options ||= {}

      @progress_indicator_count = options[:progress_indicator_count] || DEFAULT_PROGRESS_INDICATOR_COUNT
      @verbose = options.has_key?("verbose") ? options[ "verbose" ] : DEBUG
      # puts "verbose: #{@verbose.inspect}"
      @mode = options[ "mode" ] || "normal"
      @gz = options[ "gz" ]
      @initial_pattern = !!options[ "pattern" ] ? %r{#{options[ "pattern" ]}} : DEFAULT_PATTERN
      @current_pattern = @initial_pattern
      reset_file_index
      @file_names = self.class.globs_to_files( options[ "files" ] )

      if !current_file || !File.exists?( current_file )
        raise "must specify at least one valid file (and/or file_glob)"
      end

      puts "using:\n\tfiles: #{file_names}\n\tending in: #{ending}\n\tinitial_pattern: #{current_pattern_string}\n" if verbose?
    end

    def self.globs_to_files( files_or_globs )
      files_or_globs = files_or_globs.is_a?( Array ) ? files_or_globs : [ files_or_globs ]
      files_or_globs.map {|file_or_glob| Dir.glob( file_or_glob ) }.flatten
    end

    def default_pattern?
      DEFAULT_PATTERN == current_pattern
    end

    def current_pattern_string
      default_pattern? ? "<match every line>" : current_pattern
    end

    def ending
      File.extname( current_file )
    end

    def gz?
      @gz || ending[/.?gz$/]
    end

    def current_file
      file_names[ file_index ]
    end

    def reset_file_index
      @file_index = 0
    end

    def increment_file_index
      @file_index += 1
    end

    def matches?(_line, _pattern)
      return _line =~ _pattern
    rescue ArgumentError
      return false
    end

    def run
      counter = 0
      results = []
      @current_pattern = initial_pattern
      while line = next_line
        # if line[@current_pattern]
        if matches?(line, @current_pattern)
          line.strip!
          counter += 1
          unless just_count? || ( verbose? && interactive? )
            results << line
          end
          @current_pattern = prompt( line )
        end
        puts "." if verbose? && 0 == (counter % progress_indicator_count)
      end
      reset_file_index
      puts "no more files.\n" if verbose?
      if just_count?
        puts "matched #{counter} line(s)\ndone.\n"
        counter
      else
        puts "done.\n" if verbose?
        results
      end
    end

    private

    attr_reader :current_pattern, :file_index

    def verbose?
      !!@verbose
    end

    def just_count?
      @mode == "count"
    end

    def interactive?
      @mode == "interactive"
    end

    def prompt( msg )
      puts "\n>>\n#{msg}\n<<" if verbose? && msg && !just_count?

      if interactive?
        puts ". | O | <pattern: [#{current_pattern_string}]> ? "
        user_input = STDIN.gets.chomp
        puts ""
        puts "user_input: >>#{user_input.inspect}<<" if DEBUG

        case
        when /^\s*$/.match( user_input ) #corresponds w/ <enter> (or <return>)
          puts " => continuing w/ the previous pattern" if verbose?
          @current_pattern
        when "-" == user_input #interactive mode Off
          @mode = "normal"
          puts " => interactive switched mode off" if verbose?
          @current_pattern
        else #use whatever was entered
          puts " => using your input as the new search pattern" if verbose?
          %r{#{user_input}}
        end
      else
        @current_pattern
      end
    end

    def next_line
      @handle ||= get_file_handle
      while @handle.eof?
        @handle.close
        puts "trying next file..." if verbose?
        return if not_another_file?
        increment_file_index
        return unless @handle = get_file_handle
      end
      return @handle.gets
    end

    def not_another_file?
      ! (file_names.count > file_index + 1)
    end

    def get_file_handle
      if gz?
        Zlib::GzipReader.open( current_file );
      else
        File.open( current_file, 'r' )
      end
    end
  end
end
