# Require this file to append Penthouse rake tasks to ActiveRecord db rake tasks
# Enabled by default in the initializer

# shamelessly copied & adjusted from Apartment
# @see https://github.com/influitive/apartment/blob/development/lib/apartment/tasks/enhancements.rb

module Penthouse
  class RakeTaskEnhancer
    TASKS = %w(db:migrate db:rollback db:migrate:up db:migrate:down db:migrate:redo db:seed)

    class << self
      def enhance!
        TASKS.each do |name|
          task = Rake::Task[name]
          task.enhance do
            if should_enhance?
              enhance_task(task)
            end
          end
        end
      end

      def should_enhance?
        Penthouse.configuration.migrate_tenants?
      end

      def enhance_task(task)
        Rake::Task[task.name.sub(/db:/, 'penthouse:')].invoke
      end
    end

  end
end

Penthouse::RakeTaskEnhancer.enhance!
