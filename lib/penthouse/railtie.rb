require 'rails'

module Penthouse
  class Railtie < Rails::Railtie
    # Ensure rake tasks are loaded
    rake_tasks do
      load 'tasks/penthouse.rake'
      require 'penthouse/tasks/enhancements'
    end
  end
end
