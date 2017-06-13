require 'sinatra'
require 'rest-client'
require 'json'

set :port, 8000

get '/' do
  all = Aggregator.get
  JSON.pretty_generate(all)
end


class Aggregator
  APIS = [
    'expedia',
    'orbitz',
    'priceline',
    'travelocity',
    'hilton'
  ]

  def self.get
    all = []

    APIS.each do |api|
      raw_response = RestClient.get "http://localhost:9000/scrapers/#{api}"
      parsed_response = JSON.parse(raw_response)

      all << parsed_response
    end

    all
  end

end
