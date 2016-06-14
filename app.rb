require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'

set :database, { adapter: "sqlite3", database: "database.sqlite3" }

Dir.glob('./models/*.rb').each { |r| require r } 



get '/api/' do

end


# @endpoints


get '/api/locations' do
	@locations = Location.all
	json @locations
end

get '/api/media' do
	@medias = Media.all
	json @medias
end

get '/api/locations/:location' do
	
end


get '/api/media/search' do
	
end
