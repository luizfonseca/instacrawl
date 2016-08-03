class Location < ActiveRecord::Base
	has_many :medias

	def as_json(options={})
		return {
			id: self.id,
			name: self.name,
			hashtag: self.hashtag,
			latitude: self.lat,
			longitude: self.lng,
			instagram_id: self.instagram_location_id,
			address: self.address,
			media_count: self.medias.count
		}.merge(options)
		
	end
end
