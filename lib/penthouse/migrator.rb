# shamelessly copied & adjusted from Apartment
# @see https://github.com/influitive/apartment/blob/master/lib/apartment/migrator.rb
# overrides Octopus's auto-switching to shards
# @see https://github.com/thiagopradi/octopus/blob/master/lib/octopus/migration.rb

module Penthouse
  module Migrator

    extend self

    # Migrate to latest version
    # @param tenant_identifier [String, Symbol] the identifier for the tenant to switch to
    # @return [void]
    def migrate(tenant_identifier, version)
      Penthouse.switch(tenant_identifier) do
        if migrator.respond_to?(:migrate_without_octopus)
          migrator.migrate_without_octopus(migrator.migrations_paths, version)
        else
          migrator.migrate(migrator.migrations_paths, version)
        end
      end
    end

    # Migrate up/down to a specific version
    # @param tenant_identifier [String, Symbol] the identifier for the tenant to switch to
    # @param version [Integer] the version number to migrate up or down to
    # @return [void]
    def run(direction, tenant_identifier, version)
      Penthouse.switch(tenant_identifier) do
        if migrator.respond_to?(:run_without_octopus)
          migrator.run_without_octopus(direction, migrator.migrations_paths, version)
        else
          migrator.run(direction, migrator.migrations_paths, version)
        end
      end
    end

    # rollback latest migration `step` number of times
    # @param tenant_identifier [String, Symbol] the identifier for the tenant to switch to
    # @param step [Integer] how many migrations to rollback by
    # @return [void]
    def rollback(tenant_identifier, step = 1)
      Penthouse.switch(tenant_identifier) do
        if migrator.respond_to?(:rollback_without_octopus)
          migrator.rollback_without_octopus(migrator.migrations_paths, step)
        else
          migrator.rollback(migrator.migrations_paths, step)
        end
      end
    end

    def migrator
      ActiveRecord::Migrator
    end
  end
end
