[![Code Climate](https://codeclimate.com/github/ryantownsend/penthouse/badges/gpa.svg)](https://codeclimate.com/github/ryantownsend/penthouse)

Penthouse is an alternative to the excellent [Apartment gem](https://github.com/influitive/apartment) – however Penthouse is more of a framework for multi-tenancy than a library, in that it provides less out-of-the-box functionality, but should make for easier customisation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'penthouse'
```

## Usage

If you're using Rails, you just need to configure an initializer at `config/initializers/penthouse.rb`

```ruby
require 'penthouse'
# include the standard Rack app
require 'penthouse/app'
# include the automated Sidekiq integration, should you be using it
require 'penthouse/sidekiq' if defined?(Sidekiq)
# require the relevant router/runner you wish to use
require 'penthouse/routers/subdomain_router'
require 'penthouse/runners/schema_runner'

Penthouse.configure do |config|
  config.router = Penthouse::Routers::SubdomainRouter
  config.runner = Penthouse::Runners::SchemaRunner
end

Rails.application.config.middleware.use Penthouse::App
```

It's advised that if you want to customise these classes, you do so by sub-classing `Penthouse::App`, `Penthouse::Routers::BaseRouter` and/or `Penthouse::Runners::BaseRunner` within this initializer.

## Dictionary

* **Router** – this class receives a Rack request object and returns an identifier (just a string or symbol) for the tenant.
* **Runner** – this class receives the identifier (either from the router or manually switching), then looks up the tenant instance and runs the code within it.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryantownsend/penthouse.
