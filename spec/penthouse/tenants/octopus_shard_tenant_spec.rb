require 'spec_helper'
require 'octopus_helper'
require 'penthouse/tenants/octopus_shard_tenant'

RSpec.describe Penthouse::Tenants::OctopusShardTenant do
  subject { described_class.new(identifier: shard_name, shard: shard_name) }

  describe "#call" do
    context "with a valid shard" do
      let(:shard_name) { "one" }

      it 'should switch to the correct shard' do
        # we should be on the master shard
        expect(ActiveRecord::Base.connection_proxy.current_shard).to eq(Octopus.master_shard)

        subject.call do
          # we should be on the tenant shard
          expect(ActiveRecord::Base.connection_proxy.current_shard).to eq(shard_name)
        end

        # we should be back on the master shard
        expect(ActiveRecord::Base.connection_proxy.current_shard).to eq(Octopus.master_shard)
      end

      it "should switch to the public schema" do
        subject.call do
          aggregate_failures do
            # our current schema should be the public schema
            expect(Penthouse.current_schema).to eq('public')
            # our table prefix should use the public schema
            expect(ActiveRecord::Base.table_name_prefix).to eq('public.')
          end
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
