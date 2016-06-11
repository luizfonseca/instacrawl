require 'sinatra'
require './crawler.rb'

get '/api/' do

  @crawl = AleysterCrawler.new
  @crawl.request_from_instagram
  @crawl.get_script_data

end
