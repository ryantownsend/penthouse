#
# The SchemaTenant class simply switches the schema search path to allow for
# isolated data, but low overheads in terms of costs. Note: this means tenants
# will be sharing a single Postgres instance and therefore performance is
# shared.
#

require_relative './base_tenant'

module Penthouse
  module Tenants
    class SchemaTenant < BaseTenant
      attr_accessor :tenant_schema, :persistent_schemas, :default_schema
      private :tenant_schema=, :persistent_schemas=, :default_schema=

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param tenant_schema [String] your tenant's schema name in Postgres
      # @param tenant_schema [String] your tenant's schema name in Postgres
      # @param persistent_schemas [Array<String>] The schemas you always want in the search path
      # @param default_schema [String] The global schema name, usually 'public'
      def initialize(identifier, tenant_schema:, persistent_schemas: ["shared_extensions"], default_schema: "public")
        super(identifier)
        self.tenant_schema = tenant_schema
        self.persistent_schemas = Array(persistent_schemas).flatten
        self.default_schema = default_schema
        freeze
      end

      # ensures we're on the master Octopus shard, just updates the schema name
      # with the tenant name
      # @param block [Block] The code to execute within the schema
      # @yield [SchemaTenant] The current tenant instance
      def call(&block)
        begin
          # set the search path to include the tenant
          ActiveRecord::Base.connection.schema_search_path = persistent_schemas.unshift(tenant_schema).join(", ")
          block.yield(self)
        ensure
          # reset the search path back to the default
          ActiveRecord::Base.connection.schema_search_path = persistent_schemas.unshift(default_schema).join(", ")
        end
      end
    end
  end
end
