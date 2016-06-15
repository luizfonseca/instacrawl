# encoding: UTF-8

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'json'

set :database, { adapter: "sqlite3", database: "database.sqlite3" }

Dir.glob('./models/*.rb').each { |r| require r } 



get '/api/' do
  return ""
end


# @endpoints


get '/api/locations' do
  content_type :json
  
	@locations = Location.all
  JSON.pretty_generate(@locations.as_json)
end

get '/api/media' do
	@medias = Media.all
	json @medias
end


get '/api/media/search' do
  @medias = nil
  lat = params[:lat]
  lng = params[:lng]
  if lat && lng 
    @medias = Media.find_by_coord(lat,lng) 
  end

  JSON.pretty_generate(@medias.as_json)
end





get '/api/locations/:location' do
	
end


get '/api/media/search' do
	
end
