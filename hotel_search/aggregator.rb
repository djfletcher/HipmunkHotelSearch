require 'rest-client'
require 'json'
require 'timeout'

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

    # API's should take ~2 seconds to respond, if 10 seconds elapse then something
    # went wrong, and the program should interrupt and return early (or else it would sleep forever)
    begin
      Timeout.timeout(10) do
        # Wait for all api calls to return before sorting results
        sleep(0.01) until async_responses.length == 45
      end
    rescue Timeout::Error
      return JSON.generate("results" => [], "error" => "Timeout Error")
    end

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
