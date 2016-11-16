require_relative './activerecord_helper'

RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:sharder] == :octopus
      require 'octopus'
      ActiveRecord::Base.clear_all_connections! rescue nil
      ActiveRecord::Base.establish_connection YAML.load_file(File.join(File.dirname(__FILE__), "support/database.yml")).fetch("test")
      Octopus.setup do |config|
        config.environments = [:test]
        config.shards = YAML.load_file(File.join(File.dirname(__FILE__), "support/octopus.yml")).fetch("octopus").fetch("shards")
      end
    end

    example.run
  end
end

