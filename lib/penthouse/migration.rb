require "active_record"
require "active_support/core_ext/module/aliasing"

module Penthouse
  module Migration
    def self.included(base)
      base.class_eval do
        # Verbose form of alias_method_chain which is now deprecated in ActiveSupport.
        #
        # This replaces the original #annouce method with #announce_with_penthouse
        # but allows calling #annouce by using #announce_without_penthouse.
        alias_method :announce_without_penthouse, :announce
        alias_method :announce, :announce_with_penthouse
      end
    end

    def announce_with_penthouse(message)
      announce_without_penthouse("#{message} - #{current_tenant}")
    end

    def current_tenant
      "Tenant: #{Penthouse.tenant || "*** global ***"}"
    end
  end
end

ActiveRecord::Migration.send(:include, Penthouse::Migration)
