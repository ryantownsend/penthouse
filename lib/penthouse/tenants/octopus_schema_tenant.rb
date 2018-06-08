#
# The OctopusSchemaTenant class relies upon Octopus [1], it uses the master
# database and simply switches the schema search path to allow for isolated
# data, but low overheads in terms of costs. Note: this means tenants will be
# sharing a single Postgres instance and therefore performance is shared.
#
# [1]: (https://github.com/thiagopradi/octopus)
#

require_relative './schema_tenant'
require 'octopus'

module Penthouse
  module Tenants
    class OctopusSchemaTenant < SchemaTenant

      # ensures we're on the correct Octopus shard, then just updates the schema
      # name with the tenant name
      # @param shard [String, Symbol] The shard to execute within, usually master
      # @param block [Block] The code to execute within the schema
      # @yield [SchemaTenant] The current tenant instance
      # @return [void]
      def call(shard: Octopus.master_shard, &block)
        switch_shard(shard: shard) { super(&block) }
      end

      # creates the tenant schema within the master shard
      # @see Penthouse::Tenants::SchemaTenant#create
      # @return [void]
      def create(**)
        switch_shard { super }
      end

      # drops the tenant schema within the master shard
      # @see Penthouse::Tenants::SchemaTenant#delete
      # @return [void]
      def delete(**)
        switch_shard { super }
      end

      # returns whether or not the schema exists
      # @see Penthouse::Tenants::SchemaTenant#exists?
      # @return [Boolean] whether or not the schema exists in the master shard
      def exists?(**)
        switch_shard { super }
      end

      private

      def switch_shard(shard: Octopus.master_shard, &block)
        Octopus.using(shard) do
          block.call
        end
      end
    end
  end
end
