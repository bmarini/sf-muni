module SfMuni
  module Base
    def base_url
      'http://webservices.nextbus.com/service/publicXMLFeed'
    end

    def parse_xml(res)
      Nokogiri::XML(res)
    end

    # Expects `url` to be implemented in the class
    def upstream_response
      http = EM::HttpRequest.new(url).get
      logger.debug "Received #{http.response_header.status} from NextBus"
      http.response
    end

  end
end