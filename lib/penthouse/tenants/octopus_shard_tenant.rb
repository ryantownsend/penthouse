#
# The OctopusShardTenant class relies upon Octopus [1], it switches to a
# different shard per tenant, allowing for each tenant to have their own
# database, 100% isolated from other tenants in terms of data and performance.
#
# [1]: (https://github.com/thiagopradi/octopus)
#

require_relative './octopus_schema_tenant'

module Penthouse
  module Tenants
    class OctopusShardTenant < OctopusSchemaTenant

      attr_accessor :shard
      private :shard=

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param shard [String, Symbol] the configured Octopus shard to use for this tenant
      # @param tenant_schema [String] your tenant's schema name within the Postgres shard, typically just 'public' as the shard should be dedicated
      def initialize(identifer, shard:, tenant_schema: "public", **options)
        self.shard = shard
        super(identifier, tenant_schema: tenant_schema, **options)
      end

      # switches to the relevant Octopus shard, and processes the block
      # @param block [Block] The code to execute within the connection to the shard
      # @yield [ShardTenant] The current tenant instance
      # @return [void]
      def call(&block)
        super(shard: shard, &block)
      end
    end
  end
end
