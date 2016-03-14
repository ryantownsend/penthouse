require 'spec_helper'
require 'penthouse/tenants/base_tenant'

RSpec.describe Penthouse do
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

  describe ".configure" do
    let(:router_class) { Class.new(Penthouse::Routers::BaseRouter) }
    let(:runner_class) { Class.new(Penthouse::Runners::BaseRunner) }

    it "should set the configuration" do
      described_class.configure do |config|
        config.router = router_class
        config.runner = runner_class
      end
      expect(described_class.configuration.router).to eq(router_class)
      expect(described_class.configuration.runner).to eq(runner_class)
    end
  end

  describe ".switch" do
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

    it "should set the configuration" do
      described_class.switch("test", runner: TestRunner) do |tenant|
        expect(described_class.tenant).to eq("test")
        expect(tenant.identifier).to eq("test")
      end
      expect(described_class.tenant).to eq(original_tenant)
    end
  end
end
