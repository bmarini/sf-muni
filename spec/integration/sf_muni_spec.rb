require 'spec_helper'
require_relative '../../sf_muni'

describe SfMuni do
  let(:err) { Proc.new { fail "API request failed" } }

  describe "/routelist" do
    before do
      RouteList.any_instance.stub(:upstream_response).and_return <<-EOS
<?xml version="1.0" encoding="utf-8" ?> 
<body copyright="All data copyright San Francisco Muni 2011.">
<route tag="F" title="F-Market &amp; Wharves"/>
<route tag="J" title="J-Church"/>
<route tag="KT" title="KT-Ingleside/Third Street"/>
<route tag="L" title="L-Taraval"/>
<route tag="M" title="M-Ocean View"/>
<route tag="N" title="N-Judah"/>
<route tag="NX" title="NX-N Express"/>
</body>
      EOS
    end

    it 'lists routes' do
      with_api(SfMuni) do
        get_request({path: '/routelist'}, err) do |c|
          res = JSON.parse(c.response)
          res.map { |r| r['tag'] }.should == %w[ F J KT L M N NX ]
        end
      end
    end
  end

  describe "/routeconfig" do
    before do
      RouteConfig.any_instance.stub(:upstream_response).and_return <<-EOS
<?xml version="1.0" encoding="utf-8" ?> 
<body copyright="All data copyright San Francisco Muni 2011.">
<route tag="N" title="N-Judah" color="003399" oppositeColor="ffffff" latMin="37.7601699" latMax="37.7932299" lonMin="-122.5092" lonMax="-122.38798">
<stop tag="5240" title="King St &amp; 4th St" lat="37.7760599" lon="-122.39436" stopId="15240"/>
<stop tag="5237" title="King St &amp; 2nd St" lat="37.7796199" lon="-122.38982" stopId="15237"/>
<stop tag="5223" title="Judah St &amp; La Playa St" lat="37.7601699" lon="-122.50878" stopId="15223"/>
<stop tag="5216" title="Judah St &amp; 46th Ave" lat="37.7603899" lon="-122.50606" stopId="15216"/>
<direction tag="N__OB2" title="Outbound to Ocean Beach" name="Outbound" useForUI="true">
  <stop tag="5240" />
  <stop tag="5237" />
</direction>
<direction tag="N__IB3" title="Inbound to Downtown/Caltrain" name="Inbound" useForUI="true">
  <stop tag="5223" />
  <stop tag="5216" />
</direction>
</route>
</body>
      EOS
    end

    it 'lists stops for a route' do
      with_api(SfMuni) do
        get_request({path: '/routeconfig', query: { r: 'N' } }, err) do |c|
          res = JSON.parse(c.response)

          res[0]['title'].should == "Outbound to Ocean Beach"
          res[0]['stops'].map { |s| s['tag'] }.should == %w[5240 5237]

          res[1]['title'].should == "Inbound to Downtown/Caltrain"
          res[1]['stops'].map { |s| s['tag'] }.should == %w[5223 5216]
        end
      end
    end

  end
end