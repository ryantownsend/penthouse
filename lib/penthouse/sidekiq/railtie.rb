module Penthouse::Sidekiq
  class Railtie < Rails::Railtie
    initializer "penthouse.sidekiq" do
      Penthouse::Sidekiq::Middleware.run
    end
  end
end
