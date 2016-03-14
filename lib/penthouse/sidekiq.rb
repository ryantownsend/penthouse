require 'sidekiq'
require 'penthouse/sidekiq/middleware/client'
require 'penthouse/sidekiq/middleware/server'

module Penthouse
  module Sidekiq
    module Middleware

      def self.run
        ::Sidekiq.configure_client do |config|
          config.client_middleware do |chain|
            chain.add Penthouse::Sidekiq::Middleware::Client
          end
        end

        ::Sidekiq.configure_server do |config|
          config.client_middleware do |chain|
            chain.add Penthouse::Sidekiq::Middleware::Client
          end

          config.server_middleware do |chain|
            chain.insert_before ::Sidekiq::Middleware::Server::RetryJobs, Penthouse::Sidekiq::Middleware::Server
          end
        end
      end
    end
  end
end

require 'penthouse/sidekiq/railtie' if defined?(Rails)
