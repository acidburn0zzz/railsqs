# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'railsqs/version'
require 'date'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{Railsqs::RUBY_VERSION}"
  s.authors = ['opendrops']
  s.date = Date.today.strftime('%Y-%m-%d')

  s.description = <<-HERE
Railsqs is a base Rails project that you can upgrade. It is used by
opendrops to get a jump start on a working app. Use Railsqs if you're in a
rush to build something amazing; don't use it if you like missing deadlines.
  HERE

  s.email = 'support@opendrops.com'
  s.executables = ['railsqs']
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/opendrops/railsqs'
  s.license = 'MIT'
  s.name = 'railsqs'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.summary = "Generate a Rails app using opendrops's best practices. (Based on Thoughtbot's suspenders)"
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Railsqs::VERSION

  s.add_dependency 'bitters', '~> 0.10.0'
  s.add_dependency 'bundler', '~> 1.3'
  s.add_dependency 'rails', Railsqs::RAILS_VERSION

end
