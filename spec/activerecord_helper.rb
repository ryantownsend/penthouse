require "yaml"
require "pg"
require "active_record"

# Prepare the databases for testing
ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.test.yml")).fetch("default")
begin
  ActiveRecord::Base.connection.create_database("penthouse_test")
rescue
  PG::DuplicateDatabase
end
begin
  ActiveRecord::Base.connection.create_database("penthouse_octopus_one")
rescue
  PG::DuplicateDatabase
end
begin
  ActiveRecord::Base.connection.create_database("penthouse_octopus_two")
rescue
  PG::DuplicateDatabase
end

# Establish the active record connection to the test database
ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.test.yml")).fetch("test")
begin
  ActiveRecord::Base.connection.execute(IO.read("./spec/support/structure.sql"))
rescue
  PG::DuplicateTable
end

# Log everything executed in the datbase
ActiveRecord::Base.logger = Logger.new(STDOUT)
