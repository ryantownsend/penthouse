require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/tenants/schema_tenant'

RSpec.describe Penthouse::Tenants::SchemaTenant do
  let(:schema_name) { "schema_tenant_test" }
  let(:persistent_schemas) { ["shared_extensions"] }
  let(:default_schema) { "public" }

  subject(:schema_tenant) do
    described_class.new(identifier: schema_name,
      tenant_schema: schema_name,
      persistent_schemas: persistent_schemas,
      default_schema: default_schema
    )
  end

  describe "#call" do
    before(:each) { schema_tenant.create(run_migrations: false, db_schema_file: nil) }
    after(:each) { schema_tenant.delete }

    it "should switch to the relevant Postgres schema" do
      schema_tenant.call do
        expect(ActiveRecord::Base.connection.schema_search_path).to eq([schema_name, *persistent_schemas].join(", "))
      end
      expect(ActiveRecord::Base.connection.schema_search_path).to eq([default_schema, *persistent_schemas].join(", "))
    end

    it "should clear query cache before and after yielding to block" do
      relation = double("Relation")
      expect(ActiveRecord::Base.connection).to receive(:clear_query_cache).ordered
      expect(relation).to receive(:some_method).ordered
      expect(ActiveRecord::Base.connection).to receive(:clear_query_cache).ordered

      schema_tenant.call do
        relation.some_method
      end
    end
  end
end
