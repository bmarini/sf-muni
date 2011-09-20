require_relative 'common'

# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni'
# <?xml version="1.0" encoding="utf-8" ?> 
# <body copyright="All data copyright San Francisco Muni 2011.">
#   <route tag="F" title="F-Market &amp; Wharves"/>
#   ...

class RouteList < Goliath::API
  include Common
  use Goliath::Rack::JSONP

  def response(env)
    res    = upstream_response(env)
    doc    = Nokogiri::XML(res)
    result = doc.css('route').to_a.map { |n| { tag: n['tag'], title: n['title'] } }

    headers = {
      'X-Goliath'     => 'Proxy',
      'Content-Type'  => 'application/javascript',
      'Cache-Control' => 'max-age=86400, public'
    }

    [ 200, headers, result.to_json ]
  end

  def upstream_response(env)
    http = EM::HttpRequest.new(url).get
    logger.debug "Received #{http.response_header.status} from NextBus"
    http.response
  end

  def url
    base_url + '?command=routeList&a=sf-muni'
  end

end
