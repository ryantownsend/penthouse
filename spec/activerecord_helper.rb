require 'yaml'
require 'pg'
require 'active_record'

puts ActiveRecord.version

ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.yml")).fetch("test")
