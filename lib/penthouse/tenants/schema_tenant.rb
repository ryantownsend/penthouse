# frozen_string_literal: true
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
      PERSISTENT_SCHEMAS_DEFAULT = 'shared_extensions'.freeze

      include Migratable

      def self.current_search_path
        results = ActiveRecord::Base.connection.exec_query('SHOW search_path')
        results.first.fetch('search_path')
      end

      attr_accessor :tenant_schema, :persistent_schemas, :default_schema
      private :tenant_schema=, :persistent_schemas=, :default_schema=

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param tenant_schema [String] your tenant's schema name in Postgres
      # @param persistent_schemas [Array<String>] The schemas you always want in the search path
      # @param default_schema [String] The global schema name, usually 'public'
      # @param previous_schema [String] The previous schema name, usually 'public' unless dealing with nested calls.
      def initialize(identifier:, tenant_schema:, persistent_schemas: PERSISTENT_SCHEMAS_DEFAULT)
        super
        @tenant_schema = tenant_schema.freeze
        @persistent_schemas = Array(persistent_schemas).flatten.unshift(tenant_schema).join(', ').freeze
        freeze
      end

      # switches to the tenant schema to run the block, ensuring we switch back
      # afterwards, regardless of whether an exception occurs
      # @param block [Block] The code to execute within the schema
      # @yield [SchemaTenant] The current tenant instance
      # @return [void]
      def call(&block)
        previous_schemas = self.class.current_search_path
        # create a transaction wrapping all calls
        ActiveRecord::Base.transaction do
          # set the search path to include this tenant
          set_search_path(@persistent_schemas)
          # call the code
          block.yield(self)
        end
      ensure
        # reset the search path back for the previous tenant
        set_search_path(previous_schemas)
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
        result = ActiveRecord::Base.connection.exec_query(sql, 'Schema Exists')
        !result.rows.empty?
      end

      private

      # sets the Postgres search path to the given schema(s), but only if a transaction is open
      # @param schemas [Array<String>] The schemas you want to set for the current transaction's search path
      # @return [void]
      def set_search_path(*schemas)
        # we can only set a search path inside transactions, otherwise this is a no-op
        if ActiveRecord::Base.connection.transaction_open?
          sql = ActiveRecord::Base.send(:sanitize_sql_array, ["set local search_path to %s", Array(schemas).join(', ')])
          ActiveRecord::Base.connection.exec_query(sql, 'Switch Schema')
        end
      end

    end
  end
end
