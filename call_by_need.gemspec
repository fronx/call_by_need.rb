# -*- encoding: utf-8 -*-
require File.expand_path('../lib/call_by_need/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["fronx"]
  gem.email         = ["fronx@wurmus.de"]
  gem.description   = %q{A little call-by-need implementation for recreational use.}
  gem.summary       = %q{A scoped call-by-need module/class.}
  gem.homepage      = "https://github.com/fronx/call_by_need.rb"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "call_by_need"
  gem.require_paths = ["lib"]
  gem.version       = CallByNeed::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
