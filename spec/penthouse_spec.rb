require 'spec_helper'
require 'penthouse/tenants/base_tenant'

RSpec.describe Penthouse do
  TestTenant = Class.new(Penthouse::Tenants::BaseTenant) do
    def call(&block)
      block.yield(self)
    end
  end

  TestRunner = Class.new(Penthouse::Runners::BaseRunner) do
    def self.load_tenant(tenant_identifier)
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
        config.tenant_identifiers = Proc.new { %w(one two three) }
      end
      @tenants = []
      subject.each_tenant(runner: TestRunner) do |tenant|
        @tenants.push(tenant.identifier)
      end
      expect(@tenants).to eq(%w(one two three))
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
        config.tenant_identifiers = Proc.new { Array.new }
      end
      expect(subject.configuration.router).to eq(router_class)
      expect(subject.configuration.runner).to eq(runner_class)
      expect(subject.configuration.migrate_tenants).to eq(true)
      expect(subject.configuration.tenant_identifiers).to respond_to(:call)
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
  end

  describe ".tenant_identifiers" do
    subject { described_class.dup }

    context "when configured" do
      it "should use the proc defined by the configuration" do
        subject.configure do |config|
          config.tenant_identifiers = Proc.new { %w(one two three) }
        end
        expect(subject.tenant_identifiers).to eq(%w(one two three))
      end
    end

    context "when not configured" do
      it "should raise a NotImplementedError" do
        expect { subject.tenant_identifiers }.to raise_error(NotImplementedError)
      end
    end
  end
end
