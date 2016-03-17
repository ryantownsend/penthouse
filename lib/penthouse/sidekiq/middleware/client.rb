module Penthouse
  module Sidekiq
    module Middleware
      class Client
        def call(worker_class, item, queue, redis_pool=nil)
          item['tenant'] ||= Penthouse.current_tenant
          yield
        end
      end
    end
  end
end
