require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/tenants/schema_tenant'

RSpec.describe Penthouse::Tenants::SchemaTenant do
  let(:schema_name) { "schema_tenant_test" }
  let(:persistent_schemas) { ["shared_extensions"] }

  subject(:schema_tenant) do
    described_class.new(
      identifier: schema_name,
      tenant_schema: schema_name,
      persistent_schemas: persistent_schemas
    )
  end

  describe "#call" do
    before(:each) { schema_tenant.create(run_migrations: false, db_schema_file: nil) }
    after(:each) { schema_tenant.delete }

    it "should switch to the relevant Postgres schema" do
      search_path = -> {
        ActiveRecord::Base.connection.exec_query('SHOW search_path').first.fetch('search_path')
      }

      original_search_path = search_path.call
      aggregate_failures do
        schema_tenant.call do
          expect(search_path.call).to eq([schema_name, *persistent_schemas].join(', '))
        end
        expect(search_path.call).to eq(original_search_path)
      end
    end
  end
end
