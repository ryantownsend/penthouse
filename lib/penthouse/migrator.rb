require 'active_record'
require 'set'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/array/wrap'

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
        end
      end
    end

    module ClassMethods
      def migrate_with_penthouse(migrations_paths, target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          if defined?(:migrate_without_octopus)
            return migrate_without_octopus(migrations_paths, target_version, &block)
          else
            return migrate_without_penthouse(migrations_paths, target_version, &block)
          end
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do
          if defined?(:migrate_without_octopus)
            migrate_without_octopus(migrations_paths, target_version, &block)
          else
            migrate_without_penthouse(migrations_paths, target_version, &block)
          end
        end
      end

      def up_with_penthouse(migrations_paths, target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          if defined?(:up_without_octopus)
            return up_without_octopus(migrations_paths, target_version, &block)
          else
            return up_without_penthouse(migrations_paths, target_version, &block)
          end
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do
          if defined?(:up_without_octopus)
            up_without_octopus(migrations_paths, target_version, &block)
          else
            up_without_penthouse(migrations_paths, target_version, &block)
          end
        end
      end

      def down_with_penthouse(migrations_paths, target_version = nil, &block)
        unless Penthouse.configuration.migrate_tenants?
          if defined?(:down_without_octopus)
            return down_without_octopus(migrations_paths, target_version, &block)
          else
            return down_without_penthouse(migrations_paths, target_version, &block)
          end
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do
          if defined?(:down_without_octopus)
            down_without_octopus(migrations_paths, target_version, &block)
          else
            down_without_penthouse(migrations_paths, target_version, &block)
          end
        end
      end

      def run_with_penthouse(direction, migrations_paths, target_version)
        unless Penthouse.configuration.migrate_tenants?
          if defined?(:run_without_octopus)
            return run_without_octopus(direction, migrations_paths, target_version)
          else
            return run_without_penthouse(direction, migrations_paths, target_version)
          end
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do
          if defined?(:run_without_octopus)
            run_without_octopus(direction, migrations_paths, target_version)
          else
            run_without_penthouse(direction, migrations_paths, target_version)
          end
        end
      end

      def tenants_to_migrate
        if (t = ENV["tenant"] || ENV["tenants"])
          t.split(",").map(&:strip)
        end
      end
    end
  end
end

ActiveRecord::Migration.send(:include, Penthouse::Migration)
ActiveRecord::Migrator.send(:include, Penthouse::Migrator)
