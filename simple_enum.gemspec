# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_enum/version"

Gem::Specification.new do |s|
  s.name        = "simple_enum"
  s.version     = SimpleEnum::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Simple enum-like field support for models."
  s.description = "Provides enum-like fields for ActiveRecord, ActiveModel and Mongoid models."

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.authors  = ["Lukas Westermann"]
  s.email    = ["lukas.westermann@gmail.com"]
  s.homepage = "http://github.com/lwe/simple_enum"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path     = 'lib'

  s.license          = 'MIT'

  s.add_dependency "activesupport", '>= 3.0.0'
  
  s.add_development_dependency 'rake', '>= 0.9.2'
  s.add_development_dependency 'appraisal', '>= 0.4'
  s.add_development_dependency 'minitest', '>= 2.3.0'
  s.add_development_dependency 'activerecord', '>= 3.0.0'
  s.add_development_dependency 'mongoid', '~> 2.0'

  unless RUBY_PLATFORM =~ /java/
    s.add_development_dependency 'sqlite3'
  else
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
  end
end