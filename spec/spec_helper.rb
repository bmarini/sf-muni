require 'bundler'

Bundler.setup
Bundler.require

require 'goliath/test_helper'
require_relative '../application'

Goliath.env = :test

RSpec.configure do |c|
  c.include Goliath::TestHelper, :example_group => {
    :file_path => /spec\/integration/
  }
end
