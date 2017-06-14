# Hip Solution
This is my solution, implemented in Ruby, to the [Building a Hotel Search API](https://github.com/djfletcher/HotelSearch/tree/master/hotel_search) problem.

This solution is very straightforward. A single API endpoint is configured to respond to `get` requests on port 8000. When it receives a request, an [`Aggregator`](./hotel_search/aggregator.rb) class makes a call to five separate Scraper API's and aggregates the results into a single JSON response. It achieves this in just over 2 seconds (the Scraper API's 'sleep' for 2 seconds before responding to simulate real world delay) by creating a separate [thread](https://ruby-doc.org/core-2.2.0/Thread.html) for each Scraper API call, so that all Scraper HTTP request/response cycles may occur concurrently. As the asynchronous responses come in, the `Aggregator` concatenates the response onto an `async_responses` array. Once all API's have responded the `Aggregator` sorts the results by 'ecstasy' and returns the merged results as a single JSON object.

# Setup

Please follow the steps below to download and test my solution.

## Installing dependencies

In addition to the Python dependencies used by the Scraper API's, my solution relies on the following Ruby gems:
+ [Sinatra](http://www.sinatrarb.com/), which is used to configure a single API endpoint the responds to `get` requests at http://localhost:8000/hotels/search.
+ [RestClient](https://github.com/rest-client/rest-client), which is used to make HTTP requests for hotels data from each Scraper API.
+ [JSON](https://github.com/flori/json), a JSON implementation for Ruby.

1. `git clone https://github.com/djfletcher/HotelSearch.git`
2. `python setup.py develop`
3. `gem install bundler`
4. `bundle install`

## Starting Servers

There are two separate servers: the Scraper API's, which listen on port 9000, and the Aggregator API, which listens on port 8000.

1. `python -m hotel_search.scraperapi`
2. `ruby hotel_search/merged_api.rb`

## Testing

To test the Aggregator API make sure both servers are running, then run `python -m scraperapi_test`. You can also visit http://localhost:8000/hotels/search directly in your browser to see the aggregated JSON response, or by using a GUI application like [Postman](https://www.getpostman.com/).
