#
# The Penthouse::Configuration class contains all configuration options for
# Penthouse, such as which router to use.
#
# @example
#   Penthouse.configure do |config|
#     config.router = Penthouse::Routers::BaseRouter
#     config.runner = Penthouse::Runners::BaseRunner
#   end
#

module Penthouse
  class Configuration
    attr_accessor :router, :runner

    def initialize(router: nil, runner: nil)
      self.router = router
      self.runner = runner
    end
  end
end
