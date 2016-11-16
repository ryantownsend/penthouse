require 'yaml'

RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:sharder] == :active_record_shards
      require 'active_record_shards'
      ActiveRecord::Base.clear_all_connections! rescue nil
      ActiveRecord::Base.configurations = YAML.load_file(File.join(File.dirname(__FILE__), "support/active_record_shards.yml"))
      ENV['RAILS_ENV'] = 'test'
      ActiveRecord::Base.logger = Logger.new(STDOUT)
    end

    example.run
  end
end

