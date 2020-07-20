#
# The SharedTenant class relies upon Octopus [1], it uses the master
# database and expects queries to be scoped by a tenant column
#
# Note: this means tenants will be sharing a single Postgres instance and
# therefore performance is shared.
#
# [1]: (https://github.com/thiagopradi/octopus)
#

require_relative "./base_tenant"
require "octopus"

module Penthouse
  module Tenants
    class SharedTenant < BaseTenant
      # ensures we're on the correct Octopus shard, then executes the query
      # @param shard [String, Symbol] The shard to execute within, usually master
      # @param block [Block] The code to execute within the schema
      # @yield [PublicTenant] The current tenant instance
      # @return [void]
      def call(shard: Octopus.master_shard, &block)
        switch_shard(shard: shard, &block)
      end

      private

      def switch_shard(shard:, &block)
        Octopus.using(shard) do
          block.call
        end
      end
    end
  end
end
