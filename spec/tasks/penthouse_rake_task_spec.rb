require 'spec_helper'
require 'rake'
require 'penthouse/migrator'

describe "penthouse rake tasks" do

  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load 'tasks/penthouse.rake'
    # stub out rails tasks
    Rake::Task.define_task('db:migrate')
    Rake::Task.define_task('db:seed')
    Rake::Task.define_task('db:rollback')
    Rake::Task.define_task('db:migrate:up')
    Rake::Task.define_task('db:migrate:down')
    Rake::Task.define_task('db:migrate:redo')
  end

  after do
    Rake.application = nil
    ENV['VERSION'] = nil # linux users reported env variable carrying on between tests
  end

  # after(:all) do
  #   Penthouse::Test.load_schema
  # end

  let(:version) { '1234' }

  context 'database migration' do
    let(:tenant_identifiers) { %w(one two three) }
    let(:tenant_count)       { tenant_identifiers.length }

    before do
      Penthouse.stub(:tenant_identifiers).and_return(tenant_identifiers)
    end

    describe "penthouse:migrate" do
      before do
        allow(ActiveRecord::Migrator).to receive(:migrate).and_return(true)
      end

      it "should migrate public and all multi-tenant dbs" do
        expect(Penthouse::Migrator).to receive(:migrate).exactly(tenant_count).times
        @rake['penthouse:migrate'].invoke
      end
    end

    describe "penthouse:migrate:up" do

      context "without a version" do
        before do
          ENV['VERSION'] = nil
        end

        it "requires a version to migrate to" do
          expect do
            @rake['penthouse:migrate:up'].invoke
          end.to raise_error("VERSION is required")
        end
      end

      context "with version" do
        before do
          ENV['VERSION'] = version
        end

        it "migrates up to a specific version" do
          expect(Penthouse::Migrator).to receive(:run).with(:up, anything, version.to_i).exactly(tenant_count).times
          @rake['penthouse:migrate:up'].invoke
        end
      end

    end

    describe "penthouse:migrate:down" do

      context "without a version" do
        before do
          ENV['VERSION'] = nil
        end

        it "requires a version to migrate to" do
          expect do
            @rake['penthouse:migrate:down'].invoke
          end.to raise_error("VERSION is required")
        end
      end

      context "with version" do
        before do
          ENV['VERSION'] = version
        end

        it "migrates up to a specific version" do
          expect(Penthouse::Migrator).to receive(:run).with(:down, anything, version.to_i).exactly(tenant_count).times
          @rake['penthouse:migrate:down'].invoke
        end
      end

    end

    describe "penthouse:rollback" do
      let(:step) { '3' }

      it "should rollback dbs" do
        expect(Penthouse::Migrator).to receive(:rollback).exactly(tenant_count).times
        @rake['penthouse:rollback'].invoke
      end

      it "should rollback dbs STEP amount" do
        expect(Penthouse::Migrator).to receive(:rollback).with(anything, step.to_i).exactly(tenant_count).times
        ENV['STEP'] = step
        @rake['penthouse:rollback'].invoke
      end
    end
  end
end
