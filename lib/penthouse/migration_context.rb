require "active_record"
require "active_support/core_ext/module/aliasing"

module Penthouse
  module MigrationContext
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        alias_method :migrate_without_penthouse, :migrate
        alias_method :migrate, :migrate_with_penthouse

        alias_method :up_without_penthouse, :up
        alias_method :up, :up_with_penthouse

        alias_method :down_without_penthouse, :down
        alias_method :down, :down_with_penthouse

        alias_method :run_without_penthouse, :run
        alias_method :run, :run_with_penthouse

        # override any new Octopus methods with the new Penthouse ones
        alias_method :migrate_with_octopus, :migrate_with_penthouse
        alias_method :up_with_octopus, :up_with_penthouse
        alias_method :down_with_octopus, :down_with_penthouse
        alias_method :run_with_octopus, :run_with_penthouse

        alias_method :migrations_without_penthouse, :migrations
        alias_method :migrations, :migrations_with_penthouse

        # override any new Octopus methods with the new Penthouse ones
        alias_method :migrate_with_octopus, :migrate_with_penthouse
        alias_method :migrations_with_octopus, :migrations_with_penthouse
      end
    end

    # this may seem stupid but it gets around issues with Octopus
    def migrate_with_penthouse(*args)
      migrate_without_penthouse(*args)
    end

    # this may seem stupid but it gets around issues with Octopus
    def migrations_with_penthouse
      migrations_without_penthouse
    end

    module ClassMethods
      def migrate_with_penthouse(target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          return migrate_without_penthouse(target_version, &block)
        end

        wrap_penthouse do
          migrate_without_penthouse(target_version, &block)
        end
      end

      def up_with_penthouse(target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          return up_without_penthouse(target_version, &block)
        end

        wrap_penthouse do
          up_without_penthouse(target_version)
        end
      end

      def down_with_penthouse(target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          return down_without_penthouse(target_version)
        end

        wrap_penthouse do
          down_without_penthouse(target_version)
        end
      end

      def run_with_penthouse(direction, target_version)
        unless Penthouse.configuration.migrate_tenants?
          return run_without_penthouse(direction, target_version)
        end

        wrap_penthouse do
          run_without_penthouse(direction, target_version)
        end
      end

      private

      def wrap_penthouse(&block)
        if Penthouse.tenant
          block.yield
        else
          Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate, &block)
        end
      end

      def tenants_to_migrate
        return @tenants_to_migrate if defined?(@tenants_to_migrate)
        @tenants_to_migrate = begin
          if !!(t = (ENV["TENANT"] || ENV["TENANTS"]))
            t.split(",").map(&:strip)
          else
            Penthouse.tenant_identifiers
          end
        end
      end
    end
  end
end

ActiveRecord::MigrationContext.send(:include, Penthouse::MigrationContext) if ActiveRecord.version.release > Gem::Version.new("5.2.0")
