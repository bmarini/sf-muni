require 'bundler'

Bundler.setup
Bundler.require

require 'goliath/test_helper'
require_relative '../application'

Goliath.env = :test

module FixtureHelper
  def response_for(name)
    File.read File.expand_path("../fixtures/#{name}.xml", __FILE__)
  end
end

RSpec.configure do |c|
  c.include Goliath::TestHelper, :example_group => {
    :file_path => /spec\/integration/
  }
  c.include FixtureHelper, :example_group => {
    :file_path => /spec\/integration/
  }
end
