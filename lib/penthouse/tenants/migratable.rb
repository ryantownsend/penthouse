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
            # don't output all the log messages
            ActiveRecord::Schema.verbose = false
            # run the schema file to migrate this tenant
            load(db_schema_file)
          end
        else
          raise ArgumentError, "#{db_schema_file} does not exist"
        end
      end

    end
  end
end
