require 'spec_helper'
require 'penthouse/configuration'

RSpec.describe Penthouse::Configuration do
  describe '.new' do
    context 'with migrations but no DB schema file' do
      it 'should raise an ArgumentError' do
        expect do
          described_class.new(migrate_tenants: true)
        end.to raise_error(ArgumentError)
      end
    end

    context 'with migrations and a non-existant schema file' do
      it 'should raise an ArgumentError' do
        expect do
          described_class.new(migrate_tenants: true, db_schema_file: "/tmp/bla")
        end.to raise_error(ArgumentError)
      end
    end

    context 'with migrations and a valid schema file' do
      it 'should raise an ArgumentError' do
        expect do
          described_class.new(migrate_tenants: true, db_schema_file: File.join(File.dirname(__FILE__), "../support/schema.rb"))
        end.to_not raise_error(ArgumentError)
      end
    end
  end
end
