#
# This class provides an abstract for the runner interface. Whilst any Proc
# could be used, it's easiest to sub-class then overwrite the #load_tenant
# method.
#
# A runner class's responsibility in Penthouse is to receive an identifier for
# a tenant and a block, and to execute that block within the tenant
#

module Penthouse
  module Runners
    class BaseRunner

      PENTHOUSE_RUNNER_CALL_STACK = :current_penthouse_runner_call_stack

      # @param tenant_identifier [String, Symbol] The identifier for the tenant
      # @param block [Block] The code to execute within the tenant
      # @return [void]
      # @raise [Penthouse::TenantNotFound] if the tenant cannot be switched to
      def call(tenant_identifier:, &block)
        previous_tenant_identifier = call_stack.last || 'public'
        call_stack.push(tenant_identifier)

        result = nil

        begin
          load_tenant(tenant_identifier: tenant_identifier, previous_tenant_identifier: previous_tenant_identifier).call do |tenant|
            Penthouse.with_tenant(tenant.identifier) do
              result = block.yield(tenant)
            end
          end
        ensure
          call_stack.pop
        end
        result
      end

      # @abstract returns the tenant object
      # @param tenant_identifier [String, Symbol] The identifier for the tenant
      # @return [Penthouse::Tenants::BaseTenant] An instance of a tenant
      # @raise [Penthouse::TenantNotFound] if the tenant cannot be switched to
      def load_tenant(tenant_identifier:, previous_tenant_identifier: 'public')
        raise NotImplementedError
      end
      
      private
      
      def call_stack
        Thread.current[PENTHOUSE_RUNNER_CALL_STACK] ||= []
      end
      
    end
  end
end
