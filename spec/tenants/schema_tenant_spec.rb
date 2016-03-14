require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/tenants/schema_tenant'

RSpec.describe Penthouse::Tenants::SchemaTenant do
  let(:schema_name) { "schema_tenant_test" }
  let(:persistent_schemas) { ["shared_extensions"] }
  let(:default_schema) { "public" }

  before(:each) do
    ActiveRecord::Base.connection.execute("create schema if not exists #{schema_name}")
  end

  subject do
    described_class.new(schema_name,
      tenant_schema: schema_name,
      persistent_schemas: ["shared_extensions"],
      default_schema: "public"
    )
  end

  describe ".call" do
    it "should switch to the relevant Postgres schema" do
      subject.call do
        expect(ActiveRecord::Base.connection.schema_search_path).to eq([schema_name, *persistent_schemas].join(", "))
      end
      expect(ActiveRecord::Base.connection.schema_search_path).to_not include([default_schema, *persistent_schemas].join(", "))
    end
  end
end
