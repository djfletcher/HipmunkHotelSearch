# Hip Problems
This is my solution to the [Building a Hotel Search API](https://github.com/djfletcher/HotelSearch/tree/master/hotel_search) problem.

# Installation

*Assumes you're using Python 2.7*

1. `git clone https://github.com/djfletcher/HotelSearch.git`
2. `cd hipproblems`
3. `python setup.py develop`
4. `cd hotel_search/lib`
5. `gem install bundler`
6. `bundle install`
7. `cd ..`
8. `python -m scraperapi`
9. `ruby lib/merged_api.rb`

This will get the Scraper API listening on port 9000 and the Aggregator API listening on port 8000. To test the Aggregator API make sure both ports are listening, then navigate to the `hotel_search` directory and run `python -m scraperapi_test`.

If the setup script fails make sure you have [setuptools](https://pypi.python.org/pypi/setuptools) installed and try again.
