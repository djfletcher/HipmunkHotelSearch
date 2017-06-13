require 'sinatra'
require 'rest-client'
require 'json'
require_relative 'aggregator'

set :port, 8000

get '/hotels/search' do
  Aggregator.aggregate
end
