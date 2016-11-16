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
          # p "lol"
          # raise "WAT"
          # binding.pry
          payload[:octopus_shard] ||= @adapter.octopus_shard
          payload[:penthouse_prefix] = "[Tenant #{::Penthouse.tenant.inspect} on shard #{::ActiveRecord::Base.current_shard_id.inspect}]"
          @instrumenter.instrument(name, payload, &block)
        end

        def method_missing(meth, *args, &block)
          @instrumenter.send(meth, *args, &block)
        end
      end

      def octopus_shard
        @config[:octopus_shard]
      end

      def initialize(*args)
        super
        @instrumenter = InstrumenterDecorator.new(self, @instrumenter)
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:prepend, Penthouse::AbstractAdapter::ActiveRecordShard)
