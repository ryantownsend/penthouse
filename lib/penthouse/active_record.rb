# Note: we cannot monkey-patch via an extend here as we need to alter the
# underlying method to ensure all subclasses inherit the change

class ActiveRecord::Base
  DEFAULT_SCHEMA_NAME = 'public'.freeze

  class << self
    # override table name so it's calculated per prefix
    def table_name
      @table_name_cache ||= {}
      # break early if this table name is already in the cache
      if @table_name_cache.key?(table_name_prefix)
        return @table_name_cache[table_name_prefix]
      end

      # generate the table name
      table_name = compute_table_name
      self.table_name = @table_name_cache[table_name_prefix] = if table_name
        "#{table_name_prefix}#{table_name.gsub(/^.*\./, '')}"
      else
        nil
      end

      # return the table name
      @table_name
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
