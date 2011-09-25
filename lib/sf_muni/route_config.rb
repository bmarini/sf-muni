require_relative 'base'

# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=N'

module SfMuni
  class RouteConfig < Goliath::API
    include Base

    use Goliath::Rack::JSONP
    use Goliath::Rack::Params
    use Goliath::Rack::Validation::RequiredParam, { :key => 'r', :message => 'Must be a route tag' }

    def response_headers
      {
        'X-Goliath'     => 'Proxy',
        'Content-Type'  => 'application/javascript',
        'Cache-Control' => 'max-age=86400, public'
      }
    end

    def url
      base_url + "?command=routeConfig&a=sf-muni&r=#{params[:r]}"
    end

    def transform(doc)
      stops = doc.css('route > stop').to_a.map do |n|
        { id: n['stopId'], tag: n['tag'], title: n['title'], lat: n['lat'], lon: n['lon'] }
      end

      directions = doc.css('direction').to_a.map do |direction|
        {
          title: direction['title'],
          stops: direction.css('stop').to_a.map { |stop| stops.detect { |s| stop[:tag] == s[:tag] } }
        }
      end
    end
  end
end