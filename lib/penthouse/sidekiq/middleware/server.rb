module Penthouse
  module Sidekiq
    module Middleware
      class Server
        def call(worker_class, item, queue)
          Penthouse.switch(tenant_identifier: item["tenant"]) do
            yield
          end
        end
      end
    end
  end
end
