Interactively Grep for patterns.

This works particularly well for files with muli-line patterns (like
weblogs) and it handles zipped files.

The code: pretty-yucky. This is based on my very first Ruby program (and
the code was a total hack)!

But I've kept it because it's actually useful.
And hopefully by the time you see this the code will serve as an example
of the power of refactoring ;)

Basic use-case(s):
  gem install interactive_grep
  # Then, from the commandline:
  igrep -h

  # OR in your code:
  irb
    # normal ('grep') mode - support(s) regular or gzipped files
    ig = InteractiveGrep::Grepper.new("files" => "/path/to/weblog.gz",
                                      "pattern" => search_string
    )
    puts ig.run
    # => [matching_line1, matching_line2, matching_line3, etc...]

    # count ('grep -c') mode - support(s) regular or gzipped files
    ig = InteractiveGrep::Grepper.new("files" => "/path/to/weblog.gz",
                                      "pattern" => search_string,
                                      "mode" => "count"
    )
    ig.run
    # => 20

    # interactive mode - oh yeah!!!
    ig = InteractiveGrep::Grepper.new(files => "/path/to/weblog.gz",
                                      "pattern" => search_string
    )
    ig.interactive = true
    ig.run
      # every time your *current* pattern is matched,
      # the match is displayed
      # and you are prompted to:
      #   repeat the same search pattern (press enter)
      #   'S'ee what's on the next line of the file (enter S)
      #   adjust the search pattern (whatever you enter)
      #   turn 'O'ff interactive-mode (enter O)
      #    ...at which point the rest of the results will be 
      #    automatically matched using the current pattern

(See specs for more detailed use-cases ...and short-comings)
rake rspec

# TODO:
# add specs for the behavior I described above
# test-drive an API I can be proud of ;-)
# ability to record & replay grep-sessions
