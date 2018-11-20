#
# The ActiveRecordShardsTenant class relies upon ActiveRecordShards [1], it switches to a
# different shard per tenant, allowing for each tenant to have their own
# database, 100% isolated from other tenants in terms of data and performance.
#
# [1]: (https://github.com/zendesk/active_record_shards)
#

require_relative './schema_tenant'

module Penthouse
  module Tenants
    class ActiveRecordShardsTenant < SchemaTenant

      attr_accessor :shard
      private :shard=

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param shard [String, Symbol] the configured ActiveRecordShards shard to use for this tenant
      # @param tenant_schema [String] your tenant's schema name within the Postgres shard, typically just 'public' as the shard should be dedicated
      def initialize(identifier:, shard: nil, tenant_schema: "public", **options)
        self.shard = shard
        super(identifier: identifier, tenant_schema: tenant_schema, **options)
      end

      # ensures we're on the correct ActiveRecordShards shard, then just updates the schema
      # name with the tenant name
      # @param shard [String, Symbol] The shard to execute within, usually master
      # @param block [Block] The code to execute within the schema
      # @yield [SchemaTenant] The current tenant instance
      # @return [void]
      def call(&block)
        ActiveRecord::Base.on_shard(shard) do
          super(&block)
        end
      end

      # creates the tenant schema within the master shard
      # @see Penthouse::Tenants::SchemaTenant#create
      # @return [void]
      def create(*args)
        call { super }
      end

      # drops the tenant schema within the master shard
      # @see Penthouse::Tenants::SchemaTenant#delete
      # @return [void]
      def delete(**)
        call { super }
      end

      # returns whether or not the schema exists
      # @see Penthouse::Tenants::SchemaTenant#exists?
      # @return [Boolean] whether or not the schema exists in the master shard
      def exists?(**)
        call { super }
      end
    end
  end
end
