class Media < ActiveRecord::Base
	self.table_name = "medias" 

	belongs_to :location
	validates_presence_of :location

	def as_json(options={})
    return {
      distance: 0.0,
      type: self.type,
      users_in_photo: [],
      filter: "",
      tags: self.location.hashtag,
      comments: {
        count: self.comments_count
      },
      caption: self.caption,
      likes: {
        count: self.likes_count
      },
      user: {
        id: self.owner_id
      },
      link: "https://instagram.com/p/#{self.shortcode}",
      created_time: self.date,
      images: {
        low_resolution: {},
        thumbnail: {
          url: self.remote_thumb_src,
          width: self.dimension_w,
          height: self.dimension_h
        },
        standard_resolution: {
          url: self.remote_display_src,
          width: self.dimension_w,
          height: self.dimension_h
        }
      }
    }.merge(options)
		
	end

  def type
    is_video ? 'video' : 'image'
  end

  def self.find_by_coord(lat, lng)
    self.find_by_sql ["SELECT * FROM medias as md 
    JOIN locations as lc ON lc.id = md.location_id 
    WHERE lc.lat = ? AND lc.lng = ?", lat, lng]
  end
end

