require 'active_record'
require 'active_support/core_ext/module/aliasing'

module Penthouse
  module Migration
    def self.included(base)
      base.alias_method_chain :announce, :penthouse
    end

    def announce_with_penthouse(message)
      announce_without_penthouse("#{message} - #{current_tenant}")
    end

    def current_tenant
      "Tenant: #{Penthouse.tenant || '*** global ***'}"
    end
  end
end

module Penthouse
  module Migrator
    def self.included(base)
      base.extend(ClassMethods)

      base.class_eval do
        class << self
          alias_method_chain :migrate, :penthouse
          alias_method_chain :up,      :penthouse
          alias_method_chain :down,    :penthouse
          alias_method_chain :run,     :penthouse

          # override any new Octopus methods with the new Penthouse ones
          alias_method :migrate_with_octopus, :migrate_with_penthouse
          alias_method :up_with_octopus,      :up_with_penthouse
          alias_method :down_with_octopus,    :down_with_penthouse
          alias_method :run_with_octopus,     :run_with_penthouse
        end

        alias_method_chain :migrate,    :penthouse
        alias_method_chain :migrations, :penthouse

        # override any new Octopus methods with the new Penthouse ones
        alias_method :migrate_with_octopus,    :migrate_with_penthouse
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
      def migrate_with_penthouse(migrations_paths, target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          return migrate_without_penthouse(migrations_paths, target_version, &block)
        end

        wrap_penthouse do
          migrate_without_penthouse(migrations_paths, target_version, &block)
        end
      end

      def up_with_penthouse(migrations_paths, target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          return up_without_penthouse(migrations_paths, target_version, &block)
        end

        wrap_penthouse do
          up_without_penthouse(migrations_paths, target_version)
        end
      end

      def down_with_penthouse(migrations_paths, target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          return down_without_penthouse(migrations_paths, target_version)
        end

        wrap_penthouse do
          down_without_penthouse(migrations_paths, target_version)
        end
      end

      def run_with_penthouse(direction, migrations_paths, target_version)
        unless Penthouse.configuration.migrate_tenants?
          return run_without_penthouse(direction, migrations_paths, target_version)
        end

        wrap_penthouse do
          run_without_penthouse(direction, migrations_paths, target_version)
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

ActiveRecord::Migration.send(:prepend, Penthouse::Migration)
ActiveRecord::Migrator.send(:include, Penthouse::Migrator)
