#
# The SchemaTenant class simply switches the schema search path to allow for
# isolated data, but low overheads in terms of costs. Note: this means tenants
# will be sharing a single Postgres instance and therefore performance is
# shared.
#

require_relative './base_tenant'
require_relative './migratable'
require 'active_record'

module Penthouse
  module Tenants
    class SchemaTenant < BaseTenant
      include Migratable

      attr_reader :tenant_schema

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param tenant_schema [String] your tenant's schema name in Postgres
      def initialize(identifier:, tenant_schema:)
        super
        @tenant_schema = tenant_schema.freeze
        freeze
      end

      # switches to the tenant schema to run the block, ensuring we switch back
      # afterwards, regardless of whether an exception occurs
      # @param block [Block] The code to execute within the schema
      # @yield [SchemaTenant] The current tenant instance
      # @return [void]
      def call(&block)
        # add the current schema to the chain
        Penthouse.schema_chain.push @tenant_schema
        # execute the code
        block.yield(self)
      ensure
        # remove the current schema
        Penthouse.schema_chain.pop
      end

      # creates the tenant schema
      # @param run_migrations [Boolean] whether or not to run migrations, defaults to Penthouse.configuration.migrate_tenants?
      # @param db_schema_file [String] a path to the DB schema file to load, defaults to Penthouse.configuration.db_schema_file
      # @return [void]
      def create(run_migrations: Penthouse.configuration.migrate_tenants?, db_schema_file: Penthouse.configuration.db_schema_file)
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["create schema if not exists %s", @tenant_schema])
        ActiveRecord::Base.connection.exec_query(sql, 'Create Schema')
        if !!run_migrations
          migrate(db_schema_file: db_schema_file)
        end
      end

      # drops the tenant schema
      # @param force [Boolean] whether or not to drop the schema if not empty, defaults to true
      # @return [void]
      def delete(force: true)
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["drop schema if exists %s %s", @tenant_schema, force ? 'cascade' : 'restrict'])
        ActiveRecord::Base.connection.exec_query(sql, 'Delete Schema')
      end

      # returns whether or not this tenant's schema exists
      # @return [Boolean] whether or not the tenant exists
      def exists?(**)
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["select 1 from pg_namespace where nspname = '%s'", @tenant_schema])
        result = ActiveRecord::Base.connection.exec_query(sql, "Schema Exists")
        !result.rows.empty?
      end

    end
  end
end
