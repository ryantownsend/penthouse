module Penthouse
  module ActiveJob
    extend ActiveSupport::Concern

    class_methods do
      def execute(job_data)
        Penthouse.switch(job_data["tenant"]) do
          super
        end
      end
    end

    def serialize
      super.merge("tenant" => Penthouse.tenant)
    end
  end
end
