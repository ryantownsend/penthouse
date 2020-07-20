require 'spec_helper'
require 'octopus_helper'
require 'penthouse/tenants/shared_tenant'

RSpec.describe Penthouse::Tenants::SharedTenant do
  subject { described_class.new(identifier: "test") }

  describe "#call" do
    it "should switch to the master shard" do
      subject.call do
        expect(ActiveRecord::Base.connection_proxy.current_shard).to eq(Octopus.master_shard)
      end
    end

    it "should remain in the public schema" do
      subject.call do
        expect(ActiveRecord::Base.connection.schema_search_path).to include("public")
      end
    end
  end
end
