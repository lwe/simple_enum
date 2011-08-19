require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run both unit tests for AR und MongoID'
task :test do
  # thanks to https://github.com/plataformatec/devise/blob/master/Rakefile#L11
  Dir[File.join(File.dirname(__FILE__), 'test', 'orm', '*.rb')].each do |file|
    orm = File.basename(file).split(".").first
    exit 1 unless system "rake test ORM=#{orm}"
  end
end

desc 'Run unit tests, use ORM=...'
Rake::TestTask.new(:'test:unit') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
