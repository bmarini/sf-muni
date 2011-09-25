require 'goliath'
require 'goliath/rack/templates'
require 'em-synchrony/em-http'
require 'json/ext'
require 'nokogiri'
require 'haml'

$:.unshift File.expand_path('../lib', __FILE__)
require 'sf_muni'

class Template < Goliath::API
  include Goliath::Rack::Templates

  use( Rack::Static,
    :root => Goliath::Application.app_path('public'),
    :urls => ['/css', '/js'])

  def response(env)
    [ 200, {"Content-Type" => "text/html"}, haml(:index) ]
  end
end

class Application < Goliath::API
  map '/version' do
    run Proc.new { |env| [200, {"Content-Type" => "text/html"}, ["Version 0.0.1"]] }
  end

  get '/routelist', SfMuni::RouteList
  get '/routeconfig', SfMuni::RouteConfig
  get '/predictions', SfMuni::Predictions

  get '/', Template

  # not_found('/') do
  #   run Proc.new { |env| [404, {"Content-Type" => "text/html"}, ["Try /routelist, /routeconfig, or predictions"]] }
  # end
end