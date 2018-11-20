require 'spec_helper'
require 'octopus_helper'
require 'penthouse/tenants/octopus_shard_tenant'

RSpec.describe Penthouse::Tenants::OctopusShardTenant, sharder: :octopus do
  subject { described_class.new(identifier: shard_name, shard: shard_name) }

  describe "#call" do
    context "with a valid shard" do
      let(:shard_name) { "one" }

      it "should switch to the relevant shard" do
        subject.call do
          expect(ActiveRecord::Base.connection.schema_search_path).to include("public")
        end
      end
    end

    context "with an invalid shard" do
      let(:shard_name) { "invalid_shard" }

      it "should raise an exception" do
        expect do
          subject.call { true }
        end.to raise_error(RuntimeError)
      end
    end
  end
end
