require_relative './activerecord_helper'
require 'octopus'

Octopus.setup do |config|
  config.environments = [:test]
  config.shards = YAML.load_file(File.join(File.dirname(__FILE__), "support/octopus.test.yml")).fetch("octopus").fetch("shards")
end
