class ActiveRecord::Base
  DEFAULT_SCHEMA_NAME = 'public'.freeze

  # override table name so it's calculated EVERY time
  def self.table_name
    reset_table_name
  end

  # set a table name prefix which is dynamic based on the current schema
  def self.table_name_prefix
    if Penthouse.current_schema.nil?
      DEFAULT_SCHEMA_NAME
    else
      "#{Penthouse.current_schema}."
    end
  end
end
