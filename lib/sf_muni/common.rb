module SfMuni
  module Common
    def base_url
      'http://webservices.nextbus.com/service/publicXMLFeed'
    end

    def parse_xml(res)
      Nokogiri::XML(res)
    end
  end
end