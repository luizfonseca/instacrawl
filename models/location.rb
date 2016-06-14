class Location < ActiveRecord::Base
	has_many :medias

	def as_json(options={})
		return {
			name: self.name,
			hashtag: self.hashtag,
			latitude: self.lat,
			longitude: self.lng,
			instagram_id: self.instagram_id,
			address: self.address,
			media: self.medias
		}.merge(options)
		
	end
end
