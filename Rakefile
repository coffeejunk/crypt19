require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'crypt19'
    gemspec.summary = 'Crypt1.9 is a pure-ruby implementation of several encryption algorithms.'
    gemspec.description = 'Crypt is a pure-ruby implementation of a number of popular encryption algorithms. Block cyphers currently include Blowfish, GOST, IDEA, Rijndael (AES), and RC6. Cypher Block Chaining (CBC) has been implemented.'
    gemspec.email = 'jon335@gmail.com'
    gemspec.homepage = 'http://gemcutter.org/gems/crypt19'
    gemspec.authors = ['Jonathan Rudenberg', 'Richard Kernahan']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install jeweler'
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "crypt #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end