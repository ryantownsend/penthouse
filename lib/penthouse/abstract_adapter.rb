require "active_record"

module Penthouse
  module AbstractAdapter
    module ActiveRecordShard
      parent = ActiveSupport::ProxyObject

      class InstrumenterDecorator < parent
        def initialize(adapter, instrumenter)
          @adapter = adapter
          @instrumenter = instrumenter
        end

        def instrument(name, payload = {}, &block)
          payload[:penthouse_db] ||= @adapter.active_record_database
          payload[:penthouse_tenant] ||= ::Penthouse.tenant
          @instrumenter.instrument(name, payload, &block)
        end

        def method_missing(meth, *args, &block)
          @instrumenter.send(meth, *args, &block)
        end
      end

      def active_record_database
        @config[:database]
      end

      def initialize(*args)
        super
        @instrumenter = InstrumenterDecorator.new(self, @instrumenter)
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:prepend, Penthouse::AbstractAdapter::ActiveRecordShard)
