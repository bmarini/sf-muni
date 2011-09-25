require 'spec_helper'

describe SfMuni do
  let(:err) { Proc.new { fail "API request failed" } }

  describe "/routelist" do
    before do
      SfMuni::RouteList.any_instance.stub(:upstream_response).and_return( response_for('route_list') )
    end

    it 'lists routes' do
      with_api(Application) do
        get_request({path: '/routelist'}, err) do |c|
          res = JSON.parse(c.response)
          res.map { |r| r['tag'] }.should == %w[ F J KT L M N NX ]
        end
      end
    end
  end

  describe "/routeconfig" do
    before do
      SfMuni::RouteConfig.any_instance.stub(:upstream_response).and_return(response_for('route_config'))
    end

    it 'lists stops for a route' do
      with_api(Application) do
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

  describe "/predictions" do
    before do
      SfMuni::Predictions.any_instance.stub(:upstream_response).and_return(response_for('predictions'))
    end

    it 'lists predictions for a route and stop' do
      with_api(Application) do
        get_request({path: '/predictions', query: { r: 'N', s: '5240' } }, err) do |c|
          res = JSON.parse(c.response)
          res.should == [
            {
              "routeTitle" => "N-Judah",
              "stopTitle" => "Sunset Tunnel East Portal",
              "directions" => [
                { "title" => "Outbound to Ocean Beach", "predictions" => [ 295, 571, 1234, 2107, 2658 ] }
              ]
            }
          ]
        end
      end
    end
  end
end