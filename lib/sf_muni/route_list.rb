require_relative 'common'

# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni'
# <?xml version="1.0" encoding="utf-8" ?> 
# <body copyright="All data copyright San Francisco Muni 2011.">
#   <route tag="F" title="F-Market &amp; Wharves"/>
#   ...

module SfMuni
  class RouteList < Goliath::API
    include Common
    use Goliath::Rack::JSONP

    def response(env)
      res = upstream_response(env)
      doc = parse_xml(res)
      hsh = transform(doc)

      headers = {
        'X-Goliath'     => 'Proxy',
        'Content-Type'  => 'application/javascript',
        'Cache-Control' => 'max-age=86400, public'
      }

      [ 200, headers, hsh.to_json ]
    end

    def upstream_response(env)
      http = EM::HttpRequest.new(url).get
      logger.debug "Received #{http.response_header.status} from NextBus"
      http.response
    end

    def url
      base_url + '?command=routeList&a=sf-muni'
    end

    def transform(doc)
      doc.css('route').to_a.map { |n| { tag: n['tag'], title: n['title'] } }
    end
  end
end