require 'zlib'

module InteractiveGrep
  class Grepper
    DEFAULT_PATTERN = %r{.}.freeze
    DEFAULT_NUMBER_OF_LINES_TO_INDICATE = 100.freeze
    DEBUG = false.freeze

    attr_accessor :file_names, :current_pattern, :initial_pattern, :gz, :file_index, :enough_lines_to_indicate

    def initialize( options = nil )
      options ||= {}
      @enough_lines_to_indicate = options[:line_indicator_count] || DEFAULT_NUMBER_OF_LINES_TO_INDICATE
      @verbose = DEBUG || !!options[ "verbose" ]
      reset_file_index
      @file_names = options[ "files" ]
      if ( !@file_names.is_a?( Array ) ) && @file_names[/\*/]
        @file_names = Dir.glob( @file_names ).map{|fname| fname}
      end
      @file_names = [ @file_names ] unless @file_names.is_a? Array
      unless current_file && File.exists?( current_file )
        raise "must specify at least one valid file (and/or file_glob)"
      end

      @initial_pattern = !!options[ "pattern" ] ? %r{#{options[ "pattern" ]}} : DEFAULT_PATTERN
      @current_pattern = @initial_pattern

      @mode = options[ "mode" ] || "normal"

      @gz = options[ "gz" ]

      if verbose?
        puts "using:\n\tfiles: #{file_names}\n\tending in: #{ending}\n\tinitial_pattern: #{current_pattern_string}\n"
      end
    end

    def self.contains_option?(input_options, option_string)
      input_options.any?{|o| o[/^\s*\-+#{option_string}/] }
    end

    def self.usage
      puts	"usage $0 [-h]"
      puts	"\tproduces this help-message"
      puts	""

      puts	"usage $0 <input_file> [<pattern>] [<mode>]"
      puts	""
      puts 	"modes: 'interactive' (default), 'count', or 'normal'"
      puts 	"e.g."
      puts 	"./igrep.rb big_test.txt.gz"
      puts 	'./igrep.rb "/reporting/access*.gz" cvsfa=63 interactive'
      puts 	'./igrep.rb "/reporting/access*.gz" cvsfa=63 count'
      puts 	'./igrep.rb "/reporting/access*.gz" cvsfa=63 # normal-grep mode'
      puts	""
      exit
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

    def run
      counter = 0
      results = []
      @current_pattern = initial_pattern
      while line = next_line
        if line[@current_pattern]
          line.strip!
          counter += 1
          unless just_count? || ( verbose? && interactive? )
            results << line
          end
          @current_pattern = prompt( line )
        end
        if verbose?
          puts "." if 0 == (counter % enough_lines_to_indicate)
        end
      end
      reset_file_index
      puts "no more files.\n" if verbose?
      if just_count?
        if verbose?
          puts "matched #{counter} line(s)"
          puts "done.\n"
        end
        counter
      else
        puts "done.\n" if verbose?
        results
      end
    end

    private

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
      if verbose? && msg && !just_count?
        puts "\n>>\n#{msg}\n<<"
      end

      if interactive?
        puts "S | O | <pattern: [#{current_pattern_string}]> ? "
        user_input = STDIN.gets.strip
        puts ""
        if DEBUG
          puts "user_input: >>#{user_input.inspect}<<"
        end

        case
        when /^\s*$/.match( user_input ) #corresponds w/ <enter> (or <return>)
          if verbose?
            puts " => continuing w/ the previous pattern"
          end
          @current_pattern
        when [ "O", "o" ].include?( user_input ) #interactive mode Off
          @mode = "normal"
          if verbose?
            puts " => interactive switched mode off"
          end
          @current_pattern
        when [ "S", "s" ].include?( user_input ) #Show every line
          if verbose?
            puts " => showing the next line"
          end
          /./
        else #use whatever was entered
          if verbose?
            puts " => using your input as the new search pattern"
          end
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
