#
# The Penthouse::Configuration class contains all configuration options for
# Penthouse, such as which router to use.
#
# @example
#   Penthouse.configure do |config|
#     config.router = Penthouse::Routers::BaseRouter
#     config.runner = Penthouse::Runners::BaseRunner
#     config
#   end
#

module Penthouse
  class Configuration
    attr_accessor :router, :runner, :migrate_tenants, :db_schema_file, :tenants

    # @param router [Penthouse::Routers::BaseRouter] the default router for your application to use
    # @param runner [Penthouse::Runners::BaseRunner] the default runner for your application to use
    # @param migrate_tenants [Boolean] whether you want Penthouse to automatically migrate all tenants
    # @param db_schema_file [String] a path to your schema file
    #   (typically `db/schema.rb` or `db/structure.sql` in Rails)
    # @param tenants [Proc] some code which must return an hash of tenant identifiers (strings/symbols)
    #   mapped to tenant objects, which can be anything your runner needs
    def initialize(router: nil, runner: nil, migrate_tenants: false, db_schema_file: nil, tenants: -> { raise NotImplementedError })
      self.router = router
      self.runner = runner
      self.migrate_tenants = migrate_tenants
      self.db_schema_file = db_schema_file
      self.tenants = tenants

      if migrate_tenants? && !db_schema_file
        raise ArgumentError, "If you want to migrate tenants, we need a path to a DB schema file"
      elsif migrate_tenants? && !File.exist?(db_schema_file)
        raise ArgumentError, "#{db_schema_file} is not readable"
      end
    end

    # @return [Boolean] whether or not Penthouse should automatically migrate all tenants
    def migrate_tenants?
      !!migrate_tenants
    end
  end
end
