# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'penthouse/version'

Gem::Specification.new do |spec|
  spec.name          = 'penthouse'
  spec.version       = Penthouse::VERSION
  spec.authors       = ['Ryan Townsend']
  spec.email         = ['ryan@ryantownsend.co.uk']

  spec.summary       = %q{Multi-tenancy framework. Out of the box, supports Postgres schemas and per-tenant databases}
  spec.homepage      = 'https://github.com/shiftcommerce/penthouse'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bundler', '>= 1.11'

  spec.add_development_dependency 'bundler', '>= 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard', '~> 0.8.7.6'
  # testing
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'simplecov', '~> 0.11.2'
  spec.add_development_dependency 'rubocop', '~> 0.38'
  spec.add_development_dependency 'standardrb'
  # web
  spec.add_development_dependency 'rack', '~> 1.6.4'
  # db
  spec.add_development_dependency 'ar-octopus', '~> 0.9.1'
  spec.add_development_dependency 'activesupport', "#{ENV.fetch('RAILS_VERSION', '4.2.2')}"
  spec.add_development_dependency 'activerecord', "#{ENV.fetch('RAILS_VERSION', '4.2.2')}"
  spec.add_development_dependency 'pg', "#{ENV.fetch('PG_VERSION', '0.19.0')}"

  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
end
