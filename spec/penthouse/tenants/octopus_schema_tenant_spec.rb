require 'spec_helper'
require 'octopus_helper'
require 'penthouse/tenants/octopus_schema_tenant'
require_relative '../../support/models'

RSpec.describe Penthouse::Tenants::OctopusSchemaTenant do
  let(:schema_name) { "octopus_schema_tenant_test" }
  let(:db_schema_file) { File.join(File.dirname(__FILE__), '../../support/schema.rb') }

  subject(:octopus_schema_tenant) {
    described_class.new(
      identifier: schema_name,
      tenant_schema: schema_name
    )
  }

  describe "#create" do
    after(:each) do
      octopus_schema_tenant.delete
      expect(subject.exists?).to be false
    end

    context "without running migrations" do
      it "should create the relevant Postgres schema" do
        octopus_schema_tenant.create(run_migrations: false, db_schema_file: nil)
        expect(subject.exists?).to be true
      end
    end

    context "when running migrations" do
      it "should create the relevant Postgres schema and tables" do
        octopus_schema_tenant.create(run_migrations: true, db_schema_file: db_schema_file)
        octopus_schema_tenant.call do |tenant|
          expect(Post.table_name).to eq("#{schema_name}.posts")
          expect(Post.create(title: "test", description: "test")).to be_persisted
          expect(Post.count).to eq(1)
        end
      end
    end
  end
end
