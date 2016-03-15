require 'spec_helper'
require 'octopus_helper'
require 'penthouse/tenants/octopus_schema_tenant'

RSpec.describe Penthouse::Tenants::OctopusSchemaTenant do
  let(:schema_name) { "octopus_schema_tenant_test" }
  let(:persistent_schemas) { ["shared_extensions"] }
  let(:default_schema) { "public" }
  let(:db_schema_file) { File.join(File.dirname(__FILE__), '../../support/schema.rb') }

  subject do
    described_class.new(schema_name,
      tenant_schema: schema_name,
      persistent_schemas: ["shared_extensions"],
      default_schema: "public"
    )
  end

  describe "#create" do
    after(:each) do
      subject.delete
      expect(subject.exists?).to be false
    end

    it "should create to the relevant Postgres schema" do
      subject.create(run_migrations: false, db_schema_file: nil)
      expect(subject.exists?).to be true
    end
  end
end
