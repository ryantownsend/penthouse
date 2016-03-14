require 'active_record'
require 'yaml'
require 'pg'

ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.yml")).fetch("test")
