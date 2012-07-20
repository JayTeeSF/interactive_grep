require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

gemspec = eval(File.read("interactive_grep.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["interactive_grep.gemspec"] do
  system "gem build interactive_grep.gemspec"
  system "gem install interactive_grep-#{InteractiveGrep::VERSION}.gem"
end
