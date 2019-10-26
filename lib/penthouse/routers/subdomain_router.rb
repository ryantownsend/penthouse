#
# This router will load the tenant name based on a request's sub-domain
#

module Penthouse
  module Routers
    class SubdomainRouter < BaseRouter
      # Determines the tenant identifier based on the sub-domain of the request
      # @param request [Rack::Request] The request from the Rack app, used to determine the tenant
      # @return [String, Symbol] A tenant identifier
      def self.call(request)
        request.host.split(".").first
      end
    end
  end
end
