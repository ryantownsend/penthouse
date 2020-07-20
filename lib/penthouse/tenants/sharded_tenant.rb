#
# The ShardedTenant class relies upon Octopus [1], it switches to a
# different shard per tenant, allowing for each tenant to have their own
# database, 100% isolated from other tenants in terms of data and performance.
#
# [1]: (https://github.com/thiagopradi/octopus)
#

require_relative './shared_tenant'

module Penthouse
  module Tenants
    class ShardedTenant < SharedTenant
      attr_accessor :shard
      private :shard=

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param shard [String, Symbol] the configured Octopus shard to use for this tenant
      def initialize(identifier:, shard:, **options)
        self.shard = shard
        super(identifier: identifier, **options)
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
