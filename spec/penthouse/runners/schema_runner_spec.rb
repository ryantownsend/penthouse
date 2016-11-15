require 'spec_helper'
require 'activerecord_helper'
require 'penthouse/runners/schema_runner'

RSpec.describe Penthouse::Runners::SchemaRunner do
  let(:schema_name) { "schema_runner_test" }

  subject(:runner) { described_class.new }

  before(:each) do
    ActiveRecord::Base.connection.execute("create schema if not exists #{schema_name}")
  end

  def current_search_path
    ActiveRecord::Base.connection.exec_query('SHOW search_path').first.fetch('search_path')
  end

  describe ".call" do
    it "should switch to the relevant Postgres schema" do
      runner.call(tenant_identifier: schema_name) do
        expect(current_search_path).to include(schema_name)
      end
    end

    it "should honour nested switches to the relevant Postgres schema" do
      schema_1 = 'schema_1'
      schema_2 = 'schema_2'

      runner.call(tenant_identifier: schema_1) do
        aggregate_failures 'moving to schema_1' do
          expect(current_search_path).to include(schema_1)
          expect(current_search_path).not_to include('public', schema_2)
        end

        runner.call(tenant_identifier: schema_2) do
          aggregate_failures 'moving to schema_2' do
            expect(current_search_path).to include(schema_2)
            expect(current_search_path).not_to include('public', schema_1)
          end
        end

        aggregate_failures 'returning to schema_1' do
          expect(current_search_path).to include(schema_1)
          expect(current_search_path).not_to include('public', schema_2)
        end
      end
    end

  end
end
