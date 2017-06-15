# Hip Solution
This is my solution, implemented in Ruby, to the [Building a Hotel Search API](https://github.com/djfletcher/HotelSearch/tree/master/hotel_search) problem.

This solution is very straightforward. A [single API endpoint](,.hotel_search/merged_api.rbh) is configured to respond to `get` requests on port 8000. When it receives a request, an [`Aggregator`](./hotel_search/aggregator.rb) class makes a call to five separate Scraper API's and aggregates the results into a single JSON response. It achieves this in just over 2 seconds (the Scraper API's 'sleep' for 2 seconds before responding to simulate real world delay) by creating a separate [thread](https://ruby-doc.org/core-2.2.0/Thread.html) for each Scraper API call, so that all Scraper HTTP request/response cycles may occur concurrently.

```ruby
# hotel_search/aggregator.rb
async_responses = {}

APIS.each do |api|
  # Create a separate thread for each api call so they may occur concurrently
  Thread.new { async_responses[api] = Aggregator.get(api) }
end
```

As the asynchronous responses come in, the `Aggregator` stores them in an `async_responses` hash with API names as keys. Once all API's have responded, the `Aggregator` implements [mergesort](https://en.wikipedia.org/wiki/Merge_sort) to merge the sorted arrays. The merge is achieved by iterating over the first element of each array, extracting the one from the group with the highest 'ecstasy', and pushing it onto a merged array.

```ruby
# hotel_search/aggregator.rb
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
```

This solution does not optimize lookup/extraction of the hotel with the highest ecstasy because there are only 5 elements that need to be checked each time. As the number of arrays, k, being merged grows very large (i.e. many more API's were added), linear iteration over the heads of each would become a performance drag. If many more API's were added then lookup/extraction of the max could be optimized by keeping the first element of each array in a priority queue. A max heap could be used to implement this priority queue, maintaining O(n logk) insertion/extraction of the most ecstatic hotel amongst the unmerged results.

Exception handling is also included so that in the event that the API's do not respond within 10 seconds, the program terminates early and returns JSON indicating a timeout error.

# Setup

Please follow the steps below to download and test my solution.

## Installing dependencies

In addition to the Python dependencies used by the Scraper API's, my solution relies on the following Ruby gems:
+ [Sinatra](http://www.sinatrarb.com/), which is used to configure a single API endpoint the responds to `get` requests at http://localhost:8000/hotels/search.
+ [RestClient](https://github.com/rest-client/rest-client), which is used to make HTTP requests for data from each Scraper API.
+ [JSON](https://github.com/flori/json), a JSON implementation for Ruby.

1. `git clone https://github.com/djfletcher/HotelSearch.git`
2. `cd HotelSearch`
3. `python setup.py develop`
4. `gem install bundler`
5. `bundle install`

## Starting Servers

There are two separate servers: the Scraper API's, which listen on port 9000; and the Aggregator API, which listens on port 8000.

1. `python -m hotel_search.scraperapi`
2. `ruby hotel_search/merged_api.rb`

## Testing

To test the Aggregator API make sure both servers are running, then run `python -m hotel_search.scraperapi_test`. You can also visit http://localhost:8000/hotels/search directly in your browser to see the aggregated JSON response, or by using a GUI application like [Postman](https://www.getpostman.com/).
