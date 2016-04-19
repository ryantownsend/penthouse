require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/runners/schema_runner'

RSpec.describe Penthouse::Runners::SchemaRunner do
  let(:schema_name) { "schema_runner_test" }

  subject(:runner) { described_class.new }

  before(:each) do
    ActiveRecord::Base.connection.execute("create schema if not exists #{schema_name}")
  end

  describe ".call" do
    it "should switch to the relevant Postgres schema" do
      runner.call(tenant_identifier: schema_name) do
        expect(ActiveRecord::Base.connection.schema_search_path).to include(schema_name)
      end
    end
    
    it "should honour nested switches to the relevant Postgres schema" do
      schema_1 = 'schema_1'
      schema_2 = 'schema_2'
      runner.call(tenant_identifier: schema_1) do
        runner.call(tenant_identifier: schema_2) do
          expect(ActiveRecord::Base.connection.schema_search_path).not_to include(schema_1)
          expect(ActiveRecord::Base.connection.schema_search_path).to include(schema_2)
        end
        expect(ActiveRecord::Base.connection.schema_search_path).not_to include('public')
        expect(ActiveRecord::Base.connection.schema_search_path).to include(schema_1)
        expect(ActiveRecord::Base.connection.schema_search_path).not_to include(schema_2)
      end
    end
    
  end
end
