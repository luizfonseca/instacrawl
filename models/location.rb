class Location < ActiveRecord::Base
	has_many :medias

	def as_json(options={})
		return {
			name: self.name,
			hashtag: self.hashtag,
			latitude: self.lat,
			longitude: self.lng
		}.merge(options)
		
	end
end
