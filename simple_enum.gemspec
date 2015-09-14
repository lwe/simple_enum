# -*- encoding: utf-8 -*-
require File.expand_path('../lib/simple_enum/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "simple_enum"
  s.version     = SimpleEnum::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Simple enum-like field support for models."
  s.description = "Provides enum-like fields for ActiveRecord, ActiveModel and Mongoid models."

  s.required_ruby_version     = ">= 1.9.3"
  s.required_rubygems_version = ">= 2.0.0"

  s.authors  = ["Lukas Westermann"]
  s.email    = ["lukas.westermann@gmail.com"]
  s.homepage = "http://lwe.github.com/simple_enum/"

  s.files            = %w{.gitignore Rakefile Gemfile README.md LICENSE simple_enum.gemspec} + Dir['**/*.{rb,yml}']
  s.test_files       = s.files.grep(%r{^(test|spec)/})
  s.require_paths    = %w{lib}

  s.license          = 'MIT'

  s.add_dependency 'activesupport', '>= 4.0.0'

  s.add_development_dependency 'rake', '>= 10.1.0'
  s.add_development_dependency 'activerecord', '>= 4.0.0'
  s.add_development_dependency 'mongoid', '>= 4.0.0'
  s.add_development_dependency 'rspec', '~> 2.14'
end
