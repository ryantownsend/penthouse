require 'spec_helper'
require 'active_record_shards_helper'
require 'penthouse/tenants/active_record_shards_tenant'
require_relative '../../support/models'

RSpec.describe Penthouse::Tenants::ActiveRecordShardsTenant, sharder: :active_record_shards do
  SHARDS = [nil, "one"]
  SCHEMAS = ["public", "ar_schema_tenant_test"]

  SHARDS.product(SCHEMAS).each do |default_shard_name, schema_name|
    context "schema '#{schema_name}' on shard '#{default_shard_name}'" do

      subject(:active_record_shards_tenant) {
        described_class.new(
          identifier: schema_name,
          shard: shard_name,
          tenant_schema: schema_name,
          persistent_schemas: persistent_schemas,
          default_schema: default_schema
        )
      }

      let(:shard_name) { default_shard_name }
      let(:persistent_schemas) { ["shared_extensions"] }
      let(:default_schema) { "public" }
      let(:db_schema_file) { File.join(File.dirname(__FILE__), '../../support/schema.rb') }

      describe "#call" do
        context "with a valid shard" do
          it "should switch to the relevant shard" do
            subject.call do
              expect(ActiveRecord::Base.connection.schema_search_path).to include(schema_name)
            end
          end
        end

        context "with an invalid shard" do
          let(:shard_name) { "invalid_shard" }

          it "should raise an exception" do
            expect do
              subject.call { true }
            end.to raise_error(StandardError)
          end
        end
      end

      describe "#create" do
        after(:each) do
          active_record_shards_tenant.delete
          expect(subject.exists?).to be false
        end

        context "without running migrations" do
          it "should create the relevant Postgres schema" do
            active_record_shards_tenant.create(run_migrations: false, db_schema_file: nil)
            expect(subject.exists?).to be true
          end
        end

        context "when running migrations" do
          it "should create the relevant Postgres schema and tables" do
            active_record_shards_tenant.create(run_migrations: true, db_schema_file: db_schema_file)
            active_record_shards_tenant.call do |tenant|
              expect(tenant.identifier).to eq(schema_name)
              expect(Post.create(title: "test", description: "test")).to be_persisted
              expect(Post.count).to eq(1)
            end
          end
        end
      end
    end
  end
end
