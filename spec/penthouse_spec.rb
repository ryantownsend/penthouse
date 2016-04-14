require 'spec_helper'
require 'penthouse/tenants/base_tenant'

RSpec.describe Penthouse do
  TestTenant = Class.new(Penthouse::Tenants::BaseTenant) do
    def call(&block)
      block.yield(self)
    end
  end

  TestRunner = Class.new(Penthouse::Runners::BaseRunner) do
    def self.load_tenant(tenant_identifier, *args)
      TestTenant.new(tenant_identifier)
    end
  end

  let!(:original_tenant) { described_class.tenant }

  describe ".tenant=" do
    it "should set the tenant on the current thread" do
      described_class.tenant = "main_thread"
      expect(described_class.tenant).to eq("main_thread")
      (1..3).to_a.map do |i|
        Thread.new do
          described_class.tenant = "thread_#{i}"
          expect(described_class.tenant).to eq("thread_#{i}")
        end
      end.each(&:join)
      expect(described_class.tenant).to eq("main_thread")
    end
  end

  describe ".with_tenant" do
    context "when an exception occurs" do
      subject { described_class.with_tenant("test") { raise RuntimeError } }

      it "should still switch back to the original tenant after" do
        expect { subject }.to raise_error(RuntimeError)
        expect(described_class.tenant).to_not eq("test")
        expect(described_class.tenant).to eq(original_tenant)
      end
    end
  end

  describe ".each_tenant" do
    subject { described_class.dup }

    it "should use the proc defined by the configuration" do
      subject.configure do |config|
        config.tenants = Proc.new { { one: "one", two: "two", three: "three" } }
      end
      @tenants = []
      subject.each_tenant(runner: TestRunner) do |tenant|
        @tenants.push(tenant.identifier)
      end
      expect(@tenants).to eq(%i(one two three))
    end
  end

  describe ".configure" do
    let(:router_class) { Class.new(Penthouse::Routers::BaseRouter) }
    let(:runner_class) { Class.new(Penthouse::Runners::BaseRunner) }

    subject { described_class.dup }

    it "should set the configuration" do
      subject.configure do |config|
        config.router = router_class
        config.runner = runner_class
        config.migrate_tenants = true
        config.tenants = Proc.new { Hash.new }
      end
      expect(subject.configuration.router).to eq(router_class)
      expect(subject.configuration.runner).to eq(runner_class)
      expect(subject.configuration.migrate_tenants).to eq(true)
      expect(subject.configuration.tenants).to respond_to(:call)
      expect(subject.configuration).to be_frozen
    end
  end

  describe ".switch" do
    it "should set the configuration" do
      described_class.switch("test", runner: TestRunner) do |tenant|
        expect(described_class.tenant).to eq("test")
        expect(tenant.identifier).to eq("test")
      end
      expect(described_class.tenant).to eq(original_tenant)
    end
    
    it 'should honour nested switches' do
      described_class.switch("outer_test", runner: TestRunner) do |tenant|
        described_class.switch("inner_test", runner: TestRunner) do |tenant|
          expect(described_class.tenant).to eq("inner_test")
          expect(tenant.identifier).to eq("inner_test")
        end
        expect(described_class.tenant).to eq("outer_test")
        expect(tenant.identifier).to eq("outer_test")
      end
      expect(described_class.tenant).to eq(original_tenant)
    end
    
  end

  context "when tenants are configured" do
    subject { described_class.dup }

    before(:each) do
      subject.configure do |config|
        config.tenants = Proc.new { { one: "one", two: "two", three: "three" } }
      end
    end

    describe ".tenant_identifiers" do
      it "should return an array of the tenant keys" do
        expect(subject.tenant_identifiers).to eq(%i(one two three))
      end
    end

    describe ".tenants" do
      it "should return a hash as the result of the proc" do
        expect(subject.tenants).to eq({ one: "one", two: "two", three: "three" })
      end
    end
  end

  context "when tenants are not configured" do
    subject { described_class.dup }

    describe ".tenant_identifiers" do
      it "should raise a NotImplementedError" do
        expect { subject.tenant_identifiers }.to raise_error(NotImplementedError)
      end
    end

    describe ".tenants" do
      it "should raise a NotImplementedError" do
        expect { subject.tenants }.to raise_error(NotImplementedError)
      end
    end
  end
end
