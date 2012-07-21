require "bundler"
Bundler.setup

require "rspec"
require "interactive_grep"

def file_dir
  File.expand_path( '../tmp', __FILE__ )
end

def ungzipped_file_dir
  "#{file_dir}/ungzipped_files"
end

def all_file_glob
  "#{file_dir}/*/*"
end

def ungzip_glob
  "#{ungzipped_file_dir}/*"
end

def gzip_glob
  "#{gzipped_file_dir}/*"
end

def gzipped_file
  "#{gzipped_file_dir}/file.txt.gz"
end

def ungzipped_file
  "#{ungzipped_file_dir}/file.txt"
end

def gzipped_file_dir
  "#{file_dir}/gzipped_files"
end
