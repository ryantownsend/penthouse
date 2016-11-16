require "active_record"
require "active_record/log_subscriber"

module Penthouse
  module LogSubscriber
    def self.included(base)
      base.send(:attr_accessor, :penthouse_db)
      base.send(:attr_accessor, :penthouse_tenant)
      base.alias_method_chain :sql, :penthouse_shard
      base.alias_method_chain :debug, :penthouse_shard
    end

    def sql_with_penthouse_shard(event)
      self.penthouse_db = event.payload[:penthouse_db]
      self.penthouse_tenant = event.payload[:penthouse_tenant]
      sql_without_penthouse_shard(event)
    end

    def debug_with_penthouse_shard(msg)
      prefix = []
      prefix << "DB #{penthouse_db}" if penthouse_db
      prefix << "tenant #{penthouse_tenant}" if penthouse_tenant
      conn = prefix ? color("[#{prefix.join(', ')}]", ActiveSupport::LogSubscriber::GREEN, true) : ''
      debug_without_penthouse_shard(conn + msg)
    end
  end
end

ActiveRecord::LogSubscriber.send(:include, Penthouse::LogSubscriber)
