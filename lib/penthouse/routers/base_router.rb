#
# This class provides an abstract for the router interface. Whilst any Proc
# could be used, it's safest for people to sub-class to ensure that any future
# interface changes are catered for.
#
# A router class's responsibility in Penthouse is to receive a Rack::Request
# object from the App instance and return an identifier for that tenant
#

module Penthouse
  module Routers
    class BaseRouter

      # @abstract typically used by the App to receive a request and return a tenant that can be switched to
      # @param request [Rack::Request] The request from the Rack app, used to determine the tenant
      # @return [String, Symbol] A tenant identifier
      # @raise [Penthouse::TenantNotFound] if the tenant cannot be found/switched to
      def self.call(request)
        raise NotImplementedError
      end

    end
  end
end
