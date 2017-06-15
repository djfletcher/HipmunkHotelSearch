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
    # Store asynchronous responses in a hash where keys are the api names
    # and values are the sorted arrays of hotels returned by that api
    async_responses = {}

    APIS.each do |api|
      # Create a separate thread for each api call so they may occur concurrently
      Thread.new { async_responses[api] = Aggregator.get(api) }
    end

    # API's should take ~2 seconds to respond, if 10 seconds elapse then something went wrong,
    # and the program should interrupt and return early (or else it would sleep forever)
    begin
      Timeout.timeout(10) do
        # Wait for all api calls to return before sorting results
        sleep(0.01) until async_responses.length == APIS.length
      end
    rescue Timeout::Error
      return JSON.generate("results" => [], "error" => "Timeout Error")
    end

    sorted = { 'results' => Aggregator.merge(async_responses) }
    JSON.generate(sorted)
  end

  def self.get(api)
    raw_response = RestClient.get "http://localhost:9000/scrapers/#{api}"
    JSON.parse(raw_response)['results']
  end

  def self.merge(results)
    merged = []
    # Until all hotel arrays are empty, extract the hotel with the highest ecstasy
    while results.any? { |_api, hotels| !hotels.empty? }
      max = nil
      results.each do |api, hotels|
        # Save a reference to the api whose leading element has the highest ecstasy
        next if hotels.empty?
        max = api if max.nil? || more_ecstatic_head(hotels, results[max])
      end
      # Shift off the highest ecstasy hotel and push it onto the merged array
      merged << results[max].shift
    end

    merged
  end

  def self.more_ecstatic_head(hotels, max)
    hotels[0] && hotels[0]['ecstasy'] > max[0]['ecstasy']
  end

end
