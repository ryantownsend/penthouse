#
# The Penthouse::App class defines a Rack middleware to be included into your
# stack before your main application is called.
#
# @example Typically in Rails you'd use:
#   Rails.application.config.middleware.use Penthouse::App, router: Penthouse::Routers::BaseRouter
#
# This app uses the router to determine the tenant instance, then calls the
# application within that tenant.
#

require "rack/request"

module Penthouse
  class App
    attr_accessor :app, :router, :runner
    private :app=, :router=, :runner=

    # @param app the Rack application
    # @param router [#call] the class/proc to use as the router
    # @param runner [#call] the class/proc to use as the runner
    def initialize(app, router: Penthouse.configuration.router, runner: Penthouse.configuration.runner)
      self.app = app
      self.router = router
      self.runner = runner
    end

    # @param env [Hash] the environment passed from Rack
    # @raise [Penthouse::TenantNotFound] if the tenant cannot be found/switched to
    # @return [void]
    def call(env)
      request = Rack::Request.new(env)
      runner.call(tenant_identifier: router.call(request)) do
        app.call(env)
      end
    end
  end
end
