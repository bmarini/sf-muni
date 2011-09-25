require_relative 'base'

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

module SfMuni
  class Predictions < Goliath::API
    include Base

    use Goliath::Rack::JSONP
    use Goliath::Rack::Params
    use Goliath::Rack::Validation::RequiredParam, { :key => 'r', :message => 'Must be a route tag' }
    use Goliath::Rack::Validation::RequiredParam, { :key => 's', :message => 'Must be a stop tag' }

    def response(env)
      res = upstream_response
      doc = parse_xml(res)
      hsh = transform(doc)

      [ 200, {'X-Goliath' => 'Proxy', 'Content-Type' => 'application/javascript'}, hsh.to_json ]
    end

    def url
      base_url + "?command=predictions&a=sf-muni&r=#{params[:r]}&s=#{params[:s]}"
    end

    def transform(doc)
      doc.css('predictions').to_a.map do |n|
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
    end
  end
end