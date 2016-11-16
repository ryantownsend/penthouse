require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/tenants/schema_tenant'

RSpec.describe Penthouse::Tenants::SchemaTenant do
  let(:schema_name) { "schema_tenant_test" }

  subject(:schema_tenant) do
    described_class.new(
      identifier: schema_name,
      tenant_schema: schema_name
    )
  end

  describe "#call" do
    before(:each) { schema_tenant.create(run_migrations: false, db_schema_file: nil) }
    after(:each) { schema_tenant.delete }

    it "should switch to the relevant Postgres schema" do
      expect(Penthouse.current_schema).to be_nil
      schema_tenant.call do
        expect(Penthouse.current_schema).to eq(schema_name)
      end
      expect(Penthouse.current_schema).to be_nil
    end
  end
end
