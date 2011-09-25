module SfMuni
  module Base

    def base_url
      'http://webservices.nextbus.com/service/publicXMLFeed'
    end

    def response(env)
      res = upstream_response
      doc = parse_xml(res)
      hsh = transform(doc)

      [ 200, response_headers, hsh.to_json ]
    end

    # Expects `url` to be implemented in the class
    def upstream_response
      http = EM::HttpRequest.new(url).get
      logger.debug "Received #{http.response_header.status} from NextBus"
      http.response
    end

    def parse_xml(res)
      Nokogiri::XML(res)
    end

  end
end