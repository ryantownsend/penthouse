#
# This runner will simply use the SchemaTenant
#

require_relative './base_runner'
require_relative '../tenants/schema_tenant'

module Penthouse
  module Runners
    class SchemaRunner < BaseRunner

      # @param tenant_identifier [String, Symbol] The identifier for the tenant
      # @return [Penthouse::Tenants::BaseTenant] An instance of a tenant
      def load_tenant(tenant_identifier:)
        Tenants::SchemaTenant.new(
          identifier: tenant_identifier,
          tenant_schema: tenant_identifier
        )
      end

    end
  end
end
