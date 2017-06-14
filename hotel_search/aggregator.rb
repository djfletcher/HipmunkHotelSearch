require 'rest-client'
require 'json'

class Aggregator

  APIS = [
    'expedia',
    'orbitz',
    'priceline',
    'travelocity',
    'hilton'
  ]

  def self.aggregate
    async_responses = []

    APIS.each do |api|
      # Create a separate thread for each api call so they may occur concurrently
      Thread.new { async_responses.concat(Aggregator.get(api)) }
    end

    # Wait for all api calls to return before sorting results
    sleep(0.01) until async_responses.length == 45

    sorted = { 'results' => Aggregator.sort(async_responses) }
    JSON.generate(sorted)
  end

  def self.get(api)
    raw_response = RestClient.get "http://localhost:9000/scrapers/#{api}"
    JSON.parse(raw_response)['results']
  end

  def self.sort(results)
    results.sort do |res1, res2|
      res2['ecstasy'] <=> res1['ecstasy']
    end
  end

end
