# shamelessly copied & adjusted from Apartment
# @see https://github.com/influitive/apartment/blob/development/lib/apartment/migrator.rb

module Penthouse
  module Migrator

    extend self

    # Migrate to latest version
    # @param tenant_identifier [String, Symbol] the identifier for the tenant to switch to
    # @return [void]
    def migrate(tenant_identifier)
      Penthouse.switch(tenant_identifier) do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil

        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, version) do |migration|
          ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
        end
      end
    end

    # Migrate up/down to a specific version
    # @param tenant_identifier [String, Symbol] the identifier for the tenant to switch to
    # @param version [Integer] the version number to migrate up or down to
    # @return [void]
    def run(direction, tenant_identifier, version)
      Penthouse.switch(tenant_identifier) do
        ActiveRecord::Migrator.run(direction, ActiveRecord::Migrator.migrations_paths, version)
      end
    end

    # rollback latest migration `step` number of times
    # @param tenant_identifier [String, Symbol] the identifier for the tenant to switch to
    # @param step [Integer] how many migrations to rollback by
    # @return [void]
    def rollback(tenant_identifier, step = 1)
      Penthouse.switch(tenant_identifier) do
        ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
      end
    end
  end
end
