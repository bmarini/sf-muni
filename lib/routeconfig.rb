require_relative 'common'

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
  include Common

  use Goliath::Rack::JSONP
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, { :key => 'r', :message => 'Must be a route tag' }

  def response(env)
    url = base_url + "?command=routeConfig&a=sf-muni&r=#{params[:r]}"
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

    headers = {
      'X-Goliath'     => 'Proxy',
      'Content-Type'  => 'application/javascript',
      'Cache-Control' => 'max-age=86400, public'
    }

    [ 200, headers, directions.to_json ]
  end
end
