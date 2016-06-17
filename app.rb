# encoding: UTF-8

require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'json'


Dir.glob('./models/*.rb').each { |r| require r } 



get '/api/' do
  return ""
end


# @endpoints


get '/api/locations' do
  content_type :json
  
	@locations = Location.all
  json(@locations.as_json)
end

get '/api/media' do
  content_type :json
  @medias = Media.joins(:location).all.limit(200)
  json(@medias.as_json)
end


get '/api/media/search' do
  content_type :json
  @medias = nil
  lat = params[:lat]
  lng = params[:lng]
  options = {
    from: params[:from],
    to: params[:to],
    date: params[:date]
  }

  return unless lat && lng 

  if params[:from] || params[:to] || params[:date]
    @medias = Media.join(:location).find_by_coord_and_time(lat, lng, options)
  else
    @medias = Media.join(:location).find_by_coord(lat,lng) 
  end

  json(@medias.as_json)
end





get '/api/locations/:location' do
	
end


get '/api/media/search' do
	
end
