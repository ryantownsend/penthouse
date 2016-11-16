require_relative './activerecord_helper'
require 'active_record_shards'
require 'yaml'

ActiveRecord::Base.configurations = YAML.load_file(File.join(File.dirname(__FILE__), "support/active_record_shards.yml"))
ENV['RAILS_ENV'] = 'test'
ActiveRecord::Base.logger = Logger.new(STDOUT)
