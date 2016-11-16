# Note: we cannot monkey-patch via an extend here as we need to alter the
# underlying method to ensure all subclasses inherit the change

class ActiveRecord::Base
  DEFAULT_SCHEMA_NAME = 'public'.freeze

  class << self
    alias_method :original_table_name, :table_name

    # override table name so it's calculated EVERY time
    def table_name
      table_name_prefix + original_table_name.gsub(/^.*\./, '')
    end

    # set a table name prefix which is dynamic based on the current schema
    def table_name_prefix
      if Penthouse.current_schema.nil?
        "#{DEFAULT_SCHEMA_NAME}."
      else
        "#{Penthouse.current_schema}."
      end
    end
  end
end
