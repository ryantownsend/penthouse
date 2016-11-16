[![Codeship Status](https://codeship.com/projects/03e16b10-8e69-0134-64e5-76ac8288ef19/status?branch=master)](https://app.codeship.com/projects/185256) [![Code Climate](https://codeclimate.com/github/shiftcommerce/penthouse/badges/gpa.svg)](https://codeclimate.com/github/shiftcommerce/penthouse) [![RubyDocs](https://img.shields.io/badge/rubydocs-click_here-blue.svg)](http://www.rubydoc.info/github/shiftcommerce/penthouse)

Penthouse is an alternative to the excellent [Apartment gem](https://github.com/influitive/apartment) – however Penthouse is more of a framework for multi-tenancy than a library, in that it provides less out-of-the-box functionality, but should make for easier customisation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'penthouse'
```

## Basic Usage

If you're using Rails, you just need to configure an initializer at `config/initializers/penthouse.rb`

```ruby
require 'penthouse'
# include the standard Rack app
require 'penthouse/app'
# require the relevant router/runner you wish to use
require 'penthouse/routers/subdomain_router'
require 'penthouse/runners/schema_runner'

Penthouse.configure do |config|
  config.router = Penthouse::Routers::SubdomainRouter
  config.runner = Penthouse::Runners::SchemaRunner
  # enhance migrations to migrate all tenants
  config.migrate_tenants = true
  # setup a proc which will return the tenants
  config.tenants = Proc.new do
    Account.each_with_object({}) do |account, result|
      result.merge!(account.slug => account)
    end
  end
end

Rails.application.config.middleware.use Penthouse::App
```

It's advised that if you want to customise these classes, you do so by sub-classing `Penthouse::App`, `Penthouse::Routers::BaseRouter` and/or `Penthouse::Runners::BaseRunner` within this initializer.

## Octopus (shard) Usage

If you want to have multiple databases on isolated hardware, you'll need to use the Octopus tenant types. In addition to the above initializer you'll need to configure Octopus:

```ruby
require 'octopus'

Octopus.setup do |config|
  config.environments = [Rails.env]
end
```

## ActiveJob

If you are using ActiveJob, you'll need to create an `active_job.rb` initializer:

```ruby
require 'penthouse/active_job'

class ActiveJob::Base
  include Penthouse::ActiveJob
end
```

## Sidekiq

If you are using Sidekiq, you simply need to include the Penthouse module, this can be done in the `penthouse.rb` initializer:

```ruby
require 'penthouse/sidekiq'
```

## Dictionary

* **Router** – this class receives a Rack request object and returns an identifier (just a string or symbol) for the tenant.
* **Runner** – this class receives the identifier (either from the router or manually switching), then looks up the tenant instance and runs the code within it.

## Contributing

To run the test suite via the `rspec` command, you'll need PostgreSQL booted, there is a `Procfile` included in the repo, so you can boot this with foreman using `bundle exec foreman start`.

You'll need to configure `spec/support/database.yml` to match your PostgreSQL configuration for authentication etc, there is a sample included in `spec/support/database.yml.example`.

Bug reports and pull requests are welcome on GitHub at https://github.com/ryantownsend/penthouse.
