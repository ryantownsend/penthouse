require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/tenants/schema_tenant'

RSpec.describe Penthouse::Tenants::SchemaTenant do
  let(:schema_name) { "schema_tenant_test" }
  let(:persistent_schemas) { ["shared_extensions"] }
  let(:default_schema) { "public" }

  subject do
    described_class.new(schema_name,
      tenant_schema: schema_name,
      persistent_schemas: persistent_schemas,
      default_schema: default_schema
    )
  end

  describe "#call" do
    before(:each) { subject.create(run_migrations: false, db_schema_file: nil) }
    after(:each) { subject.delete }

    it "should switch to the relevant Postgres schema" do
      subject.call do
        expect(ActiveRecord::Base.connection.schema_search_path).to eq([schema_name, *persistent_schemas].join(", "))
      end
      expect(ActiveRecord::Base.connection.schema_search_path).to eq([default_schema, *persistent_schemas].join(", "))
    end
  end
end
