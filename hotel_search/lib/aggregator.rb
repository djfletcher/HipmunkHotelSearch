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
    async_responses = Queue.new

    APIS.each do |api|
      Thread.new { async_responses.enq(Aggregator.get(api)) }
    end

    merged = Aggregator.merge(async_responses)
    sorted = { 'results' => Aggregator.sort(merged) }
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

  def self.merge(async_responses)
    sleep(0.01) until async_responses.length == APIS.length
    merged = []
    merged += async_responses.deq until async_responses.empty?
    merged
  end

end
