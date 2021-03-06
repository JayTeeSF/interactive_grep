# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "interactive_grep/version"

Gem::Specification.new do |s|
  s.name        = "interactive_grep"
  s.version     = InteractiveGrep::VERSION
  s.authors     = ["JayTeeSr"]
  s.email       = ["jaytee_sr_at_his-service_dot_net"]
  s.homepage    = "https://github.com/JayTeeSF/interactive_grep"
  s.summary     = %q{My very first Ruby program, for interactively grepping through gzipped weblogs for unexpected patterns}
  s.description = %q{grep for stuff in (optionally gzipped) files ...even before you fully know what that 'stuff' looks like}
  s.rubyforge_project = "interactive_grep"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 2.11.0"
  #s.add_development_dependency "ruby-debug19"
end
