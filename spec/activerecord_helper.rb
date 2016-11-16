require 'active_record'
require 'yaml'
require 'pg'

RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:sharder].blank?
      ActiveRecord::Base.clear_all_connections! rescue nil
      ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.yml")).fetch("test")
    end

    example.run
  end
end
