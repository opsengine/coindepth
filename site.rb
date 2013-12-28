require 'sinatra'
require 'net/http'
require 'json'
require 'open-uri'

API_HOST = "localhost"
API_PORT = 4567

def get_markets
  url = "http://#{API_HOST}:#{API_PORT}/search"
  markets = JSON.load(open(url))
  return markets
end

def get_depth_data
  url = "http://#{API_HOST}:#{API_PORT}/depth"
  depth_data = JSON.load(open(url))
  return depth_data
end

get '/' do
  erb :home, :locals => {:markets => get_depth_data}
end

get '/btc' do
  erb :btc
end
