# encoding: UTF-8
require 'open-uri'
require 'json'


task :update_poi do
	@json = JSON.load(File.read('./test/poi.json'))
	@hash = @json["data"]["locales"]["pt"]["AppProjectPoi"]
	
	@hash.each do |row|
		name = row['name'].sub(/<br\/?>/, ' ')
		instagram = row['app_project_felicitometro_instagram_id']

		next if name.empty? or instagram.to_i == 0

		@location = Location.find_by name: name

		save_new_location(row) if @location.nil?
		puts "Location: #{Location.count}"

	end
end


def save_new_location(row)
	l = Location.new
	l.name 			= row['name'].sub(/<br\/?>/, ' ')
	l.instagram_id 	= row['google_places_id'] 
	l.lat 			= row['latitude']
	l.lng 			= row['longitude']
	l.address 		= row['desc_endereco']
	l.hashtag 		= row['hashtags']
	l.save!
	return l
end
