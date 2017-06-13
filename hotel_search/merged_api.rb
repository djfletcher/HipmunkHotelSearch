require 'sinatra'
require 'rest-client'
require 'json'

set :port, 8000

get '/' do
  response = RestClient.get 'localhost:9000/scrapers/expedia'
  response = JSON.parse(response)
  JSON.pretty_generate(response)
end
