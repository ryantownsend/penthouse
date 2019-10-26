require 'yaml'
require 'pg'
require 'active_record'

# Prepare the databases for testing
ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.test.yml")).fetch("default")
ActiveRecord::Base.connection.create_database("penthouse_test") rescue PG::DuplicateDatabase
ActiveRecord::Base.connection.create_database("penthouse_octopus_one") rescue PG::DuplicateDatabase
ActiveRecord::Base.connection.create_database("penthouse_octopus_two") rescue PG::DuplicateDatabase

# Establish the active record connection to the test database
ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.test.yml")).fetch("test")
ActiveRecord::Base.connection.execute(IO.read("./spec/support/structure.sql")) rescue PG::DuplicateTable

# Log everything executed in the datbase
ActiveRecord::Base.logger = Logger.new(STDOUT)
