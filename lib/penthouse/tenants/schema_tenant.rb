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

      attr_accessor :tenant_schema, :persistent_schemas, :default_schema, :previous_schema
      private :tenant_schema=, :persistent_schemas=, :default_schema=

      # @param identifier [String, Symbol] An identifier for the tenant
      # @param tenant_schema [String] your tenant's schema name in Postgres
      # @param persistent_schemas [Array<String>] The schemas you always want in the search path
      # @param default_schema [String] The global schema name, usually 'public'
      # @param previous_schema [String] The previous schema name, usually 'public' unless dealing with nested calls.
      def initialize(identifier, tenant_schema:, persistent_schemas: ["shared_extensions"], default_schema: "public", previous_schema: default_schema)
        super(identifier)
        self.tenant_schema = tenant_schema.freeze
        self.persistent_schemas = Array(persistent_schemas).flatten.freeze
        self.default_schema = default_schema.freeze
        self.previous_schema = previous_schema.freeze
        freeze
      end

      # switches to the tenant schema to run the block, ensuring we switch back
      # afterwards, regardless of whether an exception occurs
      # @param block [Block] The code to execute within the schema
      # @yield [SchemaTenant] The current tenant instance
      # @return [void]
      def call(&block)
        begin
          # set the search path to include the tenant
          ActiveRecord::Base.connection.schema_search_path = persistent_schemas.dup.unshift(tenant_schema).join(", ")
          block.yield(self)
        ensure
          # reset the search path back to the default
          ActiveRecord::Base.connection.schema_search_path = persistent_schemas.dup.unshift(previous_schema).join(", ")
        end
      end

      # creates the tenant schema
      # @param run_migrations [Boolean] whether or not to run migrations, defaults to Penthouse.configuration.migrate_tenants?
      # @param db_schema_file [String] a path to the DB schema file to load, defaults to Penthouse.configuration.db_schema_file
      # @return [void]
      def create(run_migrations: Penthouse.configuration.migrate_tenants?, db_schema_file: Penthouse.configuration.db_schema_file)
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["create schema if not exists %s", tenant_schema])
        ActiveRecord::Base.connection.exec_query(sql, 'Create Schema')
        if !!run_migrations
          migrate(db_schema_file: db_schema_file)
        end
      end

      # drops the tenant schema
      # @param force [Boolean] whether or not to drop the schema if not empty, defaults to true
      # @return [void]
      def delete(force: true)
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["drop schema if exists %s %s", tenant_schema, force ? 'cascade' : 'restrict'])
        ActiveRecord::Base.connection.exec_query(sql, 'Delete Schema')
      end

      # returns whether or not this tenant's schema exists
      # @return [Boolean] whether or not the tenant exists
      def exists?
        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["select 1 from pg_namespace where nspname = '%s'", tenant_schema])
        result = ActiveRecord::Base.connection.exec_query(sql, "Schema Exists")
        !result.rows.empty?
      end

    end
  end
end
