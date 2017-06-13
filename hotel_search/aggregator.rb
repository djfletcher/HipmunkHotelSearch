class Aggregator

  APIS = [
    'expedia',
    'orbitz',
    'priceline',
    'travelocity',
    'hilton'
  ]

  def self.aggregate
    all = []

    APIS.each do |api|
      all += Aggregator.get(api)
    end

    results = { 'results' => Aggregator.sort(all) }
    JSON.generate(results)
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
