require 'time'

class Media < ActiveRecord::Base
	self.table_name = "medias" 

	belongs_to :location
	validates_presence_of :location

  default_scope { order("to_timestamp(date)::date") }

	def as_json(options={})
    return {
      code: self.shortcode,
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
      created_time_stamp: Time.at(self.date).strftime('%Y-%m-%d %H:%M:%S'),
      images: {
        low_resolution: {
          local: self.local_thumb_src,
          url: self.remote_thumb_src,
          width: self.dimension_w,
          height: self.dimension_h       
        },
        thumbnail_resolution: {
          local: self.local_thumb_src,
          url: self.remote_thumb_src,
          width: self.dimension_w,
          height: self.dimension_h
        },
        standard_resolution: {
          local: self.local_display_src,
          url: self.remote_display_src,
          width: self.dimension_w,
          height: self.dimension_h
        }
      },
      id: self.instagram_id,
      location: nil
    }.merge(options)
		
	end

  def type
    is_video ? 'video' : 'image'
  end

  def self.find_by_coord(lat, lng)
    self.find_by_sql ["SELECT * FROM medias as md 
    JOIN locations as lc ON lc.id = md.location_id 
    WHERE lc.lat = ? AND lc.lng = ? ORDER BY to_timestamp(date) DESC LIMIT 1000", lat, lng]
  end


  def self.find_by_coord_and_time(lat, lng, time_options = {})
    
    date = time_options[:date].nil? ? Time.now.strftime('%Y-%m-%d') : Time.parse(time_options[:date]).strftime('%Y-%m-%d')
    from = time_options[:from].nil? ? "#{Time.now.hour - 1}:00" : time_options[:from]
    to   = time_options[:to].nil?  ? "#{Time.now.hour}:00" : time_options[:to]

    from_date = Time.parse("#{date} #{from}")
    to_date   = Time.parse("#{date} #{to}")

    self.find_by_sql ["SELECT * FROM medias as md 
    JOIN locations as lc ON lc.id = md.location_id 
    WHERE lc.lat = ? AND lc.lng = ? 
    AND to_timestamp(date) > ? 
    AND  to_timestamp(date) < ? ORDER BY to_timestamp(date) DESC LIMIT 1000", lat, lng, from_date, to_date]
  end
end

