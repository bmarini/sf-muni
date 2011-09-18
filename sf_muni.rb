require 'goliath'
require 'em-synchrony/em-http'
require 'json/ext'
require 'nokogiri'

BASE_URL = 'http://webservices.nextbus.com/service/publicXMLFeed'

# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni'
# <?xml version="1.0" encoding="utf-8" ?> 
# <body copyright="All data copyright San Francisco Muni 2011.">
#   <route tag="F" title="F-Market &amp; Wharves"/>
#   ...

class RouteList < Goliath::API
  use Goliath::Rack::JSONP

  def response(env)
    url = BASE_URL + '?command=routeList&a=sf-muni'
    http = EM::HttpRequest.new(url).get

    logger.debug "Received #{http.response_header.status} from NextBus"

    doc = Nokogiri::XML(http.response)
    result = doc.css('route').to_a.map { |n| { tag: n['tag'], title: n['title'] } }

    [ 200, {'X-Goliath' => 'Proxy', 'Content-Type' => 'application/javascript'}, result.to_json ]
  end
end


# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=N'
# <?xml version="1.0" encoding="utf-8" ?> 
# <body copyright="All data copyright San Francisco Muni 2011.">
#   <route tag="N" title="N-Judah" color="003399" oppositeColor="ffffff" latMin="37.7601699" latMax="37.7932299" lonMin="-122.5092" lonMax="-122.38798">
#     <stop tag="7217" title="Embarcadero Station OB" lat="37.7932299" lon="-122.39654" stopId="17217"/>
#     ...
#   <direction tag="N__OB2" title="Outbound to Ocean Beach" name="Outbound" useForUI="true">
#     <stop tag="5240" />
#     ...

class RouteConfig < Goliath::API
  use Goliath::Rack::JSONP
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, { :key => 'r', :message => 'Must be a route tag' }

  def response(env)
    url = BASE_URL + "?command=routeConfig&a=sf-muni&r=#{params[:r]}"
    http = EM::HttpRequest.new(url).get

    logger.debug "Received #{http.response_header.status} from NextBus"

    doc = Nokogiri::XML(http.response)

    stops = doc.css('route > stop').to_a.map do |n|
      { id: n['stopId'], tag: n['tag'], title: n['title'], lat: n['lat'], lon: n['lon'] }
    end

    directions = doc.css('direction').to_a.map do |direction|
      {
        title: direction['title'],
        stops: direction.css('stop').to_a.map { |stop| stops.detect { |s| stop[:tag] == s[:tag] } }
      }
    end

    [ 200, {'X-Goliath' => 'Proxy', 'Content-Type' => 'application/javascript'}, directions.to_json ]
  end
end

# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r=N&s=5240'
# <?xml version="1.0" encoding="utf-8" ?> 
# <body copyright="All data copyright San Francisco Muni 2011.">
# <predictions agencyTitle="San Francisco Muni" routeTitle="N-Judah" routeTag="N" stopTitle="Sunset Tunnel East Portal" stopTag="7252">
#   <direction title="Outbound to Ocean Beach">
#   <prediction epochTime="1316371096231" seconds="295" minutes="4" isDeparture="false" dirTag="N__OB1" vehicle="1405" block="9701" tripTag="4501126" />
#   <prediction epochTime="1316371372380" seconds="571" minutes="9" isDeparture="false" dirTag="N__OB1" vehicle="1520" block="NUNSCHED" tripTag="NsunUNSCHEDO" />
#   <prediction epochTime="1316372035377" seconds="1234" minutes="20" isDeparture="false" dirTag="N__OB1" vehicle="1535" block="NUNSCHED" tripTag="NsunUNSCHEDO" />
#   <prediction epochTime="1316372908769" seconds="2107" minutes="35" isDeparture="false" dirTag="N__OB1" vehicle="1470" block="NUNSCHED" tripTag="NsunUNSCHEDO" />
#   <prediction epochTime="1316373459579" seconds="2658" minutes="44" isDeparture="false" dirTag="N__OB1" vehicle="1422" block="NUNSCHED" tripTag="NsunUNSCHEDO" />
#   </direction>
# <message text="www.sfmta.com or&#10;311 for Muni info."/>
# <message text="No Elevator at&#10;Powell Station"/>
# <message text="PROOF OF PAYMENT&#10;is required when&#10;on a Muni vehicle&#10;or in a station."/>
# <message text="Save time &amp; money!&#10;Get a Clipper card"/>
# </predictions>
# </body>

class Predictions < Goliath::API
  use Goliath::Rack::JSONP
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, { :key => 'r', :message => 'Must be a route tag' }
  use Goliath::Rack::Validation::RequiredParam, { :key => 's', :message => 'Must be a stop tag' }

  def response(env)
    url = BASE_URL + "?command=predictions&a=sf-muni&r=#{params[:r]}&s=#{params[:s]}"
    http = EM::HttpRequest.new(url).get

    logger.debug "Received #{http.response_header.status} from NextBus"

    doc = Nokogiri::XML(http.response)

    predictions = doc.css('predictions').to_a.map do |n|
      {
        routeTitle: n['routeTitle'],
        stopTitle:  n['stopTitle'],
        directions: n.css('direction').to_a.map do |dir|
          {
            title: dir['title'],
            predictions: dir.css('prediction').to_a.map do |pre|
              pre['seconds'].to_i
            end
          }
        end
      }
    end

    [ 200, {'X-Goliath' => 'Proxy', 'Content-Type' => 'application/javascript'}, predictions.to_json ]
  end
  
end

class SfMuni < Goliath::API
  map '/version' do
    run Proc.new { |env| [200, {"Content-Type" => "text/html"}, ["Version 0.0.1"]] }
  end

  get '/routelist', RouteList
  get '/routeconfig', RouteConfig
  get '/predictions', Predictions

  not_found('/') do
    run Proc.new { |env| [404, {"Content-Type" => "text/html"}, ["Try /routelist, /routeconfig, or predictions"]] }
  end
end