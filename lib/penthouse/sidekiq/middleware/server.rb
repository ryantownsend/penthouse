module Apartment::Sidekiq::Middleware
  class Server
    def call(worker_class, item, queue)
      Penthouse.router.switch(item['tenant']) do
        yield
      end
    end
  end
end
