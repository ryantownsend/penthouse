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

          # override any new Octopus methods with the new Penthouse ones
          alias_method :migrate_with_octopus, :migrate_with_penthouse
          alias_method :up_with_octopus,      :up_with_penthouse
          alias_method :down_with_octopus,    :down_with_penthouse
          alias_method :run_with_octopus,     :run_with_penthouse
        end
      end
    end

    module ClassMethods
      def migrate_with_penthouse(migrations_paths, target_version = nil, &block)
        puts "#migrate_with_penthouse called"

        unless Penthouse.configuration.migrate_tenants?
          puts "Skipping penthouse integration"
          return migrate_without_penthouse(migrations_paths, target_version, &block)
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do |tenant|
          puts "Migrating #{tenant.identifier}"
          if defined?(:migrate_without_octopus)
            puts "calling #migrate_without_octopus"
            migrate_without_octopus(migrations_paths, target_version, &block)
          else
            puts "calling #migrate_without_penthouse"
            migrate_without_penthouse(migrations_paths, target_version, &block)
          end
        end
      end

      def up_with_penthouse(migrations_paths, target_version = nil, &block)
        puts "#up_with_penthouse called"

        unless Penthouse.configuration.migrate_tenants?
          puts "Skipping penthouse integration"
          return up_without_penthouse(migrations_paths, target_version, &block)
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do |tenant|
          puts "Migrating #{tenant.identifier}"
          if defined?(:up_without_octopus)
            puts "calling #up_without_octopus"
            up_without_octopus(migrations_paths, target_version, &block)
          else
            puts "calling #up_without_penthouse"
            up_without_penthouse(migrations_paths, target_version, &block)
          end
        end
      end

      def down_with_penthouse(migrations_paths, target_version = nil, &block)
        puts "#down_with_penthouse called"

        unless Penthouse.configuration.migrate_tenants?
          puts "Skipping penthouse integration"
          return down_without_penthouse(migrations_paths, target_version, &block)
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do |tenant|
          puts "Migrating #{tenant.identifier}"
          if defined?(:down_without_octopus)
            puts "calling #down_without_octopus"
            down_without_octopus(migrations_paths, target_version, &block)
          else
            puts "calling #down_without_penthouse"
            down_without_penthouse(migrations_paths, target_version, &block)
          end
        end
      end

      def run_with_penthouse(direction, migrations_paths, target_version)
        puts "#run_with_penthouse called"

        unless Penthouse.configuration.migrate_tenants?
          puts "Skipping penthouse integration"
          return run_without_penthouse(direction, migrations_paths, target_version)
        end

        Penthouse.each_tenant(tenant_identifiers: tenants_to_migrate) do |tenant|
          puts "Migrating #{tenant.identifier}"
          if defined?(:run_without_octopus)
            puts "calling #run_without_octopus"
            run_without_octopus(direction, migrations_paths, target_version)
          else
            puts "calling #run_without_penthouse"
            run_without_penthouse(direction, migrations_paths, target_version)
          end
        end
      end

      def tenants_to_migrate
        return @tenants_to_migrate if defined?(@tenants_to_migrate)
        @tenants_to_migrate = begin
          if (t = ENV["TENANT"] || ENV["TENANTS"])
            t.split(",").map(&:strip)
          else
            Penthouse.tenant_identifiers
          end
        end
        puts "#tenants_to_migrate = #{@tenants_to_migrate}"
        @tenants_to_migrate
      end
    end
  end
end

ActiveRecord::Migration.send(:include, Penthouse::Migration)
ActiveRecord::Migrator.send(:include, Penthouse::Migrator)
