require "penthouse/version"
require "penthouse/configuration"
require "penthouse/routers/base_router"
require "penthouse/runners/base_runner"

module Penthouse
  class TenantNotFound < RuntimeError; end

  class << self
    # Retrieves the currently active tenant identifier
    # @return [String, Symbol] the current tenant name
    def tenant
      Thread.current[:tenant]
    end

    # Sets the currently active tenant identifier
    # @param tenant_identifier [String, Symbol] the identifier for the tenant
    def tenant=(tenant_identifier)
      Thread.current[:tenant] = tenant_identifier
    end

    # Similar to Penthouse.tenant=, except this will switch back after the given
    # block has finished executing
    # @param tenant_identifier [String, Symbol] the identifier for the tenant
    # @param default_tenant [String, Symbol] the identifier for the tenant to return to
    # @param block [Block] the code to execute
    # @yield [String, Symbol] the identifier for the tenant
    def with_tenant(tenant_identifier, default_tenant: tenant, &block)
      self.tenant = tenant_identifier
      block.yield(tenant_identifier)
    ensure
      self.tenant = default_tenant
    end

    # Executes the given block of code within a given tenant
    # @param tenant_identifier [String, Symbol] the identifier for the tenant
    # @param runner [Penthouse::Runners::BaseRunner] an optional runner to use, defaults to the one configured
    # @param block [Block] the code to execute
    def switch(tenant_identifier, runner: configuration.runner, &block)
      runner.call(tenant_identifier, &block)
    end

    # Allows you to configure the router of Penthouse
    # @yield [Penthouse::Configuration]
    def configure(&block)
      # allow the configuration by the block
      block.yield(self.configuration)
      # prevent modification of configuration once set
      self.configuration.freeze
    end

    # Returns the current configuration of Penthouse
    # @return [Penthouse::Configuration]
    def configuration
      @configuration ||= Configuration.new(
        router: Routers::BaseRouter,
        runner: Runners::BaseRunner
      )
    end
  end
end
