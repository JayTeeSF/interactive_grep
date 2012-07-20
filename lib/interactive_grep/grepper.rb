module InteractiveGrep
  class Grepper
    require 'zlib'

    @@DEBUG = false
    attr_accessor :in_file, :ending, :def_pattern, :interactive, :counter, :just_count, :gz

    def initialize(in_file,def_pattern=".",just_count=false,interactive=nil)
      @counter = 0
      @file_index = 0
      @in_file = [ in_file.chomp ]
      m = /(\.[^\.]+)$/.match(@in_file[0])

      @ending = m[1] || ''

      # handle glob...
      if /\*/.match(@in_file[0])
        @in_file = Dir.glob(@in_file[0]).map{|fname| fname}
      end

      @def_pattern = /#{def_pattern}/; #%r{ #{def_pattern} }
      if interactive && just_count
        just_count = false
      end

      @just_count = just_count
      @interactive = interactive
      @gz = false
      if '.gz' == @ending
        @gz = true
      end

      if @@DEBUG
        print "using:\n\tin_file: #{@in_file}\n\tw/ ending:"
        print "#{@ending}\n\tdef_pattern: #{@def_pattern}\n"
      end
    end

    def prompt(pattern, msg, display=true)
      if display && msg
        @counter += 1
        if !@just_count
          if @@DEBUG
            puts "" 
            puts ">>"
          end
          print msg
          if @@DEBUG
            puts "<<"
          end
          puts ""
        end
      end

      if @interactive.nil?
        if @@DEBUG
          puts "interactive mode is off"
        end
        pattern
      else
        puts "S | O | <pattern: [#{pattern}]> ? "
        user_input = STDIN.gets.chomp
        puts ""
        if @@DEBUG
          puts "user_input: >>#{user_input}<<"
        end

        case
        when /^\s*$/.match(user_input) #corresponds w/ <enter> (or <return>)
          if @@DEBUG
            puts "user hit <return> (cont w/ same pattern)"
          end
          pattern
        when ( (user_input == "o") || (user_input == "O") ) #interactive mode Off
          @interactive = nil
          if @@DEBUG
            puts "turned interactive mode off"
          end
          pattern
        when ( (user_input == "s") || (user_input == "S") ) #Show every line
          if @@DEBUG
            puts "show next line"
          end
          /./
        else #use whatever was entered
          if @@DEBUG
            puts "use whatever was entered"
          end
          %r{#{user_input}}
        end
      end
    end

    def run(display_results=true)
      results = []
      while (1 + @file_index) < @in_file.count
        myfh = get_file_handle()
        pattern = @def_pattern
        while line = myfh.gets
          if pattern.match(line)
            if @@DEBUG
              puts ""
            end
            if line
              line.strip!
              results << line
            end
            pattern = prompt( pattern, line, display_results )
            if @@DEBUG
              puts ""
            end
          end
          if @@DEBUG
            puts "."
          end
        end
      end
      puts "count: #{@counter}" if @just_count
      results
    end

    def get_file_handle
      handle = nil
      if @gz
        handle = Zlib::GzipReader.open(@in_file[@file_index]);
      else
        handle = File.open(@in_file[@file_index], 'r')
      end
      @file_index += 1
      handle
    end
  end
end
