require 'goliath'
require 'goliath/rack/templates'
require 'em-synchrony/em-http'
require 'json/ext'
require 'nokogiri'
require 'haml'

require_relative 'lib/common'
require_relative 'lib/routelist'
require_relative 'lib/routeconfig'
require_relative 'lib/predictions'

class Template < Goliath::API
  include Goliath::Rack::Templates

  use( Rack::Static,
    :root => Goliath::Application.app_path('public'),
    :urls => ['/css', '/js'])

  def response(env)
    [ 200, {"Content-Type" => "text/html"}, haml(:index) ]
  end
end

class SfMuni < Goliath::API
  map '/version' do
    run Proc.new { |env| [200, {"Content-Type" => "text/html"}, ["Version 0.0.1"]] }
  end

  get '/routelist', RouteList
  get '/routeconfig', RouteConfig
  get '/predictions', Predictions

  get '/', Template

  # not_found('/') do
  #   run Proc.new { |env| [404, {"Content-Type" => "text/html"}, ["Try /routelist, /routeconfig, or predictions"]] }
  # end
end