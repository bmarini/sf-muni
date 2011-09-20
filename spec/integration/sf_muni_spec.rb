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
end