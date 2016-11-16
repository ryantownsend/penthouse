require "active_record"

module Penthouse
  module LogSubscriber
    def self.included(base)
      base.send(:attr_accessor, :penthouse_prefix)
      base.alias_method_chain :sql, :penthouse_shard
      base.alias_method_chain :debug, :penthouse_shard
    end

    def sql_with_penthouse_shard(event)
      self.penthouse_prefix = event.payload[:penthouse_prefix]
      sql_without_penthouse_shard(event)
    end

    def debug_with_penthouse_shard(msg)
      conn = penthouse_prefix ? color(penthouse_prefix, ActiveSupport::LogSubscriber::GREEN, true) : ''
      debug_without_penthouse_shard(conn + msg)
    end
  end
end

ActiveRecord::LogSubscriber.send(:include, Penthouse::LogSubscriber)
