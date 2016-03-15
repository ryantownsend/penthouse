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

    # Wraps Penthouse.switch and simply executes the block of code for each
    # tenant within Penthouse.tenant_identifiers
    # @param default_tenant [String, Symbol] the identifier for the tenant to return to
    # @param block [Block] the code to execute
    # @yield [String, Symbol] the identifier for the tenant
    def each_tenant(default_tenant: tenant, runner: configuration.runner, &block)
      tenant_identifiers.each do |tenant_identifier|
        switch(tenant_identifier, runner: runner, &block)
      end
    end

    # Executes the given block of code within a given tenant
    # @param tenant_identifier [String, Symbol] the identifier for the tenant
    # @param runner [Penthouse::Runners::BaseRunner] an optional runner to use, defaults to the one configured
    # @param block [Block] the code to execute
    # @yield [Penthouse::Tenants::BaseTenant] the tenant instance
    def switch(tenant_identifier, runner: configuration.runner, &block)
      runner.call(tenant_identifier, &block)
    end

    # Loads the tenant and creates their data store
    # @param tenant_identifier [String, Symbol] the identifier for the tenant
    # @see Penthouse::Tenants::BaseTenant#delete
    def create(tenant_identifier, runner: configuration.runner, **options)
      switch(tenant_identifier, runner: runner) do |tenant|
        tenant.create(**options)
      end
    end

    # Loads the tenant and deletes their data store
    # @param tenant_identifier [String, Symbol] the identifier for the tenant
    # @see Penthouse::Tenants::BaseTenant#delete
    def delete(tenant_identifier, runner: configuration.runner, **options)
      switch(tenant_identifier, runner: runner) do |tenant|
        tenant.delete(**options)
      end
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

    # Returns a array of tenant identifiers based on the configured setting
    # @return [Array<String, Symbol>] the list of tenant identifiers
    def tenant_identifiers
      configuration.tenant_identifiers.call
    end
  end
end
