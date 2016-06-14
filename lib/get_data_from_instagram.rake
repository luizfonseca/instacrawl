require 'nokogiri'
require 'open-uri'
require 'json'

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.80 Safari/537.36"
@locations = Location.all
@active_location = nil


task :get_by_hashtag do

	@locations.each do |location|
		list = location.hashtag.split(',')
		list.each do |hashtag|
			@active_location = location
			find_and_save_media({ hashtag: hashtag })
		end
	end

end


task :get_by_location do

	@locations.each do |location|
		list = location.hashtag.split(',').strip!
		puts list
		# list.each do |hashtag|
		#find_and_save_media(location, hashtag)
		# end
	end

end


def find_and_save_media(options = {})
	if options[:hashtag]
		hashtag = options[:hashtag].strip
		request_from_instagram(hashtag_url(hashtag), hashtag)
	end
end

def request_from_instagram(url, page_name)
	name = page_name == '' ? 'page' : page_name
	page = Nokogiri::HTML(open(url, 'User-Agent' => USER_AGENT), nil, "UTF-8")
	open("temp/#{name}.html", 'w') do |file|
		file << page 
	end
	puts "#{Time.now}  - Page temp/#{name}.html saved... [#{url}]"

	get_script_data(page_name)
end


def get_script_data(page) 
	puts "#{Time.now}  - Page #{page} getting scrapped... "

	# Begin crawling	
	page_src 	= "./temp/#{page}.html"
	script_src 	= "temp/script-#{page}.txt"

	html = Nokogiri::HTML(open(page_src))
	html.css("script").each do |script|

		if /window._sharedData/.match(script.content) 
			open(script_src, 'w') do |file|
				file << script
			end
		end
	end
	puts "#{Time.now} - Page #{page_src} > script saved."
	parse_and_save_media(script_src)
end


def parse_and_save_media(script_src)

	file = File.read(script_src)

	file = file.sub(/<script type="text\/javascript">window\._sharedData =/, '')
	file = file.sub(/;<\/script>/, '')

	open(script_src, 'w') do |f|
		f << file
	end


	json = JSON.load(File.read(script_src))
	entry = json['entry_data']
	save_tag_media(entry['TagPage'].first) if entry['TagPage']	
	#save_location_media(location, entry['LocationsPage']) if entry['LocationsPage']	
end



def save_tag_media(entry)
	entry['tag']['media']['nodes'].each do |media|
		save_media(media)
	end
end

def save_media(data)
	media = Media.find_by shortcode: data['code']

	unless media.nil?
		puts "#{data['code']} -  Media already saved"
		return
	end

	m = Media.new
	m.caption			= data['caption']
	m.shortcode			= data['code']
	m.date				= data['date']
	m.dimension_w 		= data['dimensions']['width']
	m.dimension_h 		= data['dimensions']['height']
	m.comments_count 	= data['comments']['count']
	m.likes_count		= data['likes']['count']
	m.owner_id 			= data['owner']['id']
	m.remote_thumb_src	= data['thumbnail_src']
	m.remote_display_src = data['display_src']
	m.instagram_id		= data['id']
	m.is_video			= data['is_video']
	m.location 			= @active_location
	m.save!
	puts "Saved media #{m.shortcode}"
end

def hashtag_url(hashtag)
	return "https://www.instagram.com/explore/tags/#{hashtag}"
end


def location_url(location_id)
	return "https://www.instagram.com/explore/locations/#{location_id}"
end

