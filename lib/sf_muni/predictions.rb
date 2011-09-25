require_relative 'base'

# curl 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r=N&s=5240'

module SfMuni
  class Predictions < Goliath::API
    include Base

    use Goliath::Rack::JSONP
    use Goliath::Rack::Params
    use Goliath::Rack::Validation::RequiredParam, { :key => 'r', :message => 'Must be a route tag' }
    use Goliath::Rack::Validation::RequiredParam, { :key => 's', :message => 'Must be a stop tag' }

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