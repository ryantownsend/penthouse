require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/runners/schema_runner'

RSpec.describe Penthouse::Runners::SchemaRunner do
  let(:schema_name) { "schema_runner_test" }

  subject(:runner) { described_class.new }

  before(:each) do
    ActiveRecord::Base.connection.execute("create schema if not exists #{schema_name}")
  end

  describe ".call" do
    it "should switch to the relevant Postgres schema" do
      runner.call(tenant_identifier: schema_name) do
        expect(Penthouse.current_schema).to eq(schema_name)
      end
    end

    it "should honour nested switches to the relevant Postgres schema" do
      db_schema_file = File.join(File.dirname(__FILE__), '../../support/schema.rb')

      tenants = %w(schema_1 schema_2).map do |schema_name|
        schema_tenant = Penthouse::Tenants::SchemaTenant.new(
          identifier: schema_name,
          tenant_schema: schema_name
        )
        schema_tenant.create(run_migrations: true, db_schema_file: db_schema_file)
        schema_tenant
      end

      runner.call(tenant_identifier: tenants.first.identifier) do
        aggregate_failures 'moving to the top-level tenant' do
          # we should move to the top-level schema
          expect(Penthouse.current_schema).to eq(tenants.first.tenant_schema)
          # we should update the post table name
          expect(Post.table_name).to eq("#{tenants.first.tenant_schema}.posts")
        end

        runner.call(tenant_identifier: tenants.last.identifier) do
          aggregate_failures 'moving to the second-level tenant' do
            # we should move to the nested schema
            expect(Penthouse.current_schema).to eq(tenants.last.tenant_schema)
            # we should update the post table name
            expect(Post.table_name).to eq("#{tenants.last.tenant_schema}.posts")
          end
        end

        aggregate_failures 'moving back to the top-level tenant' do
          # we should return to the top-level schema
          expect(Penthouse.current_schema).to eq(tenants.first.tenant_schema)
          # we should revert the post table name
          expect(Post.table_name).to eq("#{tenants.first.tenant_schema}.posts")
        end
      end
    end

  end
end
