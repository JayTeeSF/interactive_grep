Interactively Grep for patterns.

This works particularly well for files with muli-line patterns (like
weblogs) and it handles zipped files.

The code: horrible. This is my very first ruby program!
I keep it simply because it's useful.
One day I'll actually fix the code ;-)

Basic use-case(s):
  gem install interactive_grep
  # from the commandline:
  igrep -h

  # in your code:
  irb
    # standard 'grep' (for optionally gzipped files)
    ig = InteractiveGrep::Grepper.new("/path/to/my/weblog.gz", search_pattern_string)
    results = ig.run
    puts results
    # => [matching_line1, matching_line2, matching_line3, etc...]

    # standard 'grep -c' (for optionally gzipped files)
    ig = InteractiveGrep::Grepper.new("/path/to/my/weblog.gz", search_pattern_string, true)
    ig.run
    # => 20  <-- yes, that third 'magic' initialization param caused
                 the grepper to merely "count" the number of matches

    # *** interactive grep (for optionally gzipped files) ***
    ig = InteractiveGrep::Grepper.new("/path/to/my/weblog.gz", search_pattern_string)
    ig.interactive = true
    ig.run
      # every time your *current* pattern is matched, the output is
      # displayed ane you are prompted to:
      # repeat the pattern search (just hit return)
      # update the pattern (i.e. to find the next level of detail)

(See specs for more detailed use-cases.)
rake rspec

# TODO: re-write this TDD-style
