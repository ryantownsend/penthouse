#
# This class provides an abstract for the tenant interface. Whilst any Proc
# could be used, it's safest for people to sub-class to ensure that any future
# interface changes are catered for.
#
# A tenant class's responsibility is to receive a block, around which it should
# handle switching to the given tenant's configuration, ensuring that if an
# exception occurs, the configuration is reset back to the global configuration.
#
module Penthouse
  module Tenants
    module Migratable

      # @param db_schema_file [String] a path to the DB schema file to load, defaults to Penthouse.configuration.db_schema_file
      # @return [void]
      def migrate(db_schema_file: Penthouse.configuration.db_schema_file)
        if File.exist?(db_schema_file)
          # run the migrations within this schema
          call do
            read_schema(db_schema_file)
          end
        else
          raise ArgumentError, "#{db_schema_file} does not exist"
        end
      end

      private 

      def read_schema(db_schema_file)
        case db_schema_file.extname
        when '.rb'
          load_ruby_schema(db_schema_file)
        when '.sql'
          load_sql_schema(db_schema_file)
        else
          raise ArgumentError, "Unrecognized schema file extension"
        end
      end

      def load_ruby_schema(db_schema_file)
        # don't output all the log messages
        ActiveRecord::Schema.verbose = false
        # run the schema file to migrate this tenant
        load(db_schema_file)
      end

      def load_sql_schema(db_schema_file)
        sql = process_schema_file(db_schema_file)
        
        ActiveRecord::Base.transaction do
          with_limited_logging { ActiveRecord::Base.connection.execute(sql) }
        end
      end

      def with_limited_logging
        temp_logger = Logger.new(STDOUT).tap { |l| l.level = Logger::ERROR }
        current_logger = ActiveRecord::Base.logger

        ActiveRecord::Base.logger = temp_logger
        yield
        ActiveRecord::Base.logger = current_logger
      end

      def process_schema_file(db_schema_file)
        sql = File.read(db_schema_file)
        sanitize_sql(sql)
      end

      def sanitize_sql(sql)
        sql
          .gsub(/SET search_path.*;/, '')
          .gsub(/CREATE SCHEMA/, 'CREATE SCHEMA IF NOT EXISTS')
      end
    end
  end
end
