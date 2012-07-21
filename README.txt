Interactively Grep for patterns.

This works particularly well for exploring multi-line pattern even in gzip'd files (i.e. weblogs)

Why? This is based on my very first Ruby program (the code was a total hack)!

I kept it because it's actually useful.
Hopefully by the time you get this the code (v1.0), it will serve as an example of the power of refactoring ;)

Basic use-case(s):
  gem install interactive_grep
  # Then, from the commandline:
  igrep -h

  # OR in your code:
  irb
    # normal ('grep') mode
    ig = InteractiveGrep::Grepper.new(
           "files" => "/path/to/weblog.gz",
           "pattern" => search_string
    )
    puts ig.run
    # => [matching_line1, ..., matching_lineN]

    # count ('grep -c') mode
    ig = InteractiveGrep::Grepper.new(
           "files" => "/path/to/weblog.gz",
           "pattern" => search_string,
           "mode" => "count"
    )
    ig.run
    # => 20

    # interactive mode - oh yeah!!!
    ig = InteractiveGrep::Grepper.new(
           files => "/path/to/weblog.gz",
           "pattern" => search_string
           "mode" => "interactive"
    )
    ig.run
      # every line matching the current pattern is displayed
      # and you're prompted to:
      #   repeat the current search (press enter)
      #
      #   turn off interactive-mode (enter '-'*)
      #    -- grep remainder of file(s) for current pattern
      #
      #   modify the current pattern (whatever you enter)
      #    e.g. to explore one-line at a time enter "." (dot)
      #    *note: to search for a dash, escape it (i.e. "\-")

(See specs for more detailed use-cases ...and short-comings)
rake rspec

# TODO:
# specs the behavior I've already described
# test-drive an API I can be proud of ;-)
# refactor (DRY-up and modularize)
# add ability to record & replay grep-sessions
# add support for zip, bzip, etc..
