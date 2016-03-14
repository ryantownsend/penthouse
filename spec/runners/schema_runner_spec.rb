require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/runners/schema_runner'

RSpec.describe Penthouse::Runners::SchemaRunner do
  let(:schema_name) { "test" }

  before(:each) do
    ActiveRecord::Base.connection.execute("create schema if not exists #{schema_name}")
  end

  describe ".call" do
    it "should switch to the relevant Postgres schema" do
      described_class.call(schema_name) do
        expect(ActiveRecord::Base.connection.schema_search_path).to include(schema_name)
      end
    end
  end
end
