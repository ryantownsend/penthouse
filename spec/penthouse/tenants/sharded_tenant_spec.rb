require "spec_helper"
require "octopus_helper"
require "penthouse/tenants/sharded_tenant"

RSpec.describe Penthouse::Tenants::ShardedTenant do
  subject { described_class.new(identifier: shard_name, shard: shard_name) }

  describe "#call" do
    context "with a valid shard" do
      let(:shard_name) { "one" }

      it "should switch to the relevant shard" do
        subject.call do
          expect(ActiveRecord::Base.connection_proxy.current_shard).to eq(shard_name)
        end
      end

      it "should remain in the public schema" do
        subject.call do
          expect(ActiveRecord::Base.connection.schema_search_path).to include("public")
        end
      end

      it "should yield the tenant" do
        subject.call do |tenant|
          expect(tenant).to be_kind_of(described_class)
        end
      end
    end

    context "with an invalid shard" do
      let(:shard_name) { "invalid_shard" }

      it "should raise an exception" do
        expect {
          subject.call { true }
        }.to raise_error(RuntimeError)
      end
    end
  end
end
