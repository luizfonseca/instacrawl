require 'nokogiri'
require 'open-uri'
require 'uri'
require 'json'

# OPEN URI configs
USER_AGENT        = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.82 Safari/537.36"
@locations        = Location.all

# Instagram
@active_location  = nil
@active_hashtag   = nil
@active_counter   = 0
@has_next_page    = true


# Ruby wide-available object
@active_location_obj  = nil


task :get_by_location do
	@locations.each do |location|

		next if location.instagram_location_id.to_i == 0
		@active_location = location.instagram_location_id 
		@active_location_obj  = location
		
		find_and_save_media({ location: @active_location }) 
		sleep 2	
	end
end

task :get_by_hashtag do

  @locations.each do |location|
    list = location.hashtag.split(',')
    list.each do |hashtag|
      next if ['N/A', ''].include?(hashtag.to_s)

      @active_hashtag       = hashtag
      @active_location_obj  = location
      find_and_save_media({ hashtag: @active_hashtag })
      sleep 2 # So we dont fetch it every nanosecond
    end
  end

end



# Just decoupling
def find_and_save_media(options = {})
  if options[:hashtag]
    hashtag = options[:hashtag].strip
    request_from_instagram(hashtag_url(hashtag), hashtag)
	elsif options[:location]
		request_from_instagram(location_url(options[:location]), options[:location])	
  end

end


# Simple request page from instagram and save it
# using Nokogiri lib
def request_from_instagram(url, page_name)

  puts "#{Time.now}  - Fetching [#{url}]"

  name = page_name == '' ? 'page' : page_name
  page = Nokogiri::HTML(open(url))
  open("temp/#{name}.html", 'w') do |file|
    file << page 
  end
  puts "#{Time.now}  - Page temp/#{name}.html saved... [#{url}]"

  get_script_data(page_name)
end



# We fetch the HTML for the <script> tag
# containing the shared data object
def get_script_data(page) 
  puts "#{Time.now}  - Page #{page} getting scrapped... "

  # Begin crawling	
  page_src 	= "./temp/#{page}.html"
  script_src 	= "temp/script-#{page}.txt"

  html = Nokogiri::HTML(open(page_src))
  html.css("script").each do |script|

    if /window._sharedData/.match(script.content) 
      puts "#{Time.now} -  Matched script"

      open(script_src, 'w') do |file|
        file << script
      end
    end
  end
  puts "#{Time.now} - Page #{page_src} > script saved."
  parse_script(script_src)
end




# Parse the script for the sharedData object and save it
# as JSON
def parse_script(script_src)

  file = File.read(script_src)

  file = file.sub(/<script type="text\/javascript">window\._sharedData =/, '')
  file = file.sub(/;<\/script>/, '')

  open(script_src, 'w') do |f|
    f << file
  end

  json = JSON.load(File.read(script_src))
  entry = json['entry_data']
  #puts entry.inspect


  scrap_tag_media(entry['TagPage'].first['tag']['media']) if entry['TagPage'] and entry['TagPage'].first['tag']['media']['nodes'].size != 0	
  scrap_tag_media(entry['LocationsPage'].first['location']['media']) if entry['LocationsPage'] and entry['LocationsPage'].first['location']['media']['nodes'].size != 0	
end



def scrap_tag_media(entry)
  data          = entry 
  start_cursor  = data['page_info']['end_cursor']

  puts "#{Time.now} - Looping through the page script"

  loop_through(data['nodes']) if data['nodes'].size > 0

  query_tag_instagram(start_cursor)
end




def query_tag_instagram(start_cursor)
	if !@active_location.nil?
		url = query_location_url(@active_location, start_cursor)
	else
		url = query_hashtag_url(@active_hashtag, start_cursor)
	end

  open(url, 'User-Agent' => USER_AGENT) do |stream|

    unless stream.status.first == '200'
      puts "#{Time.now} - Hashtag #{@active_hashtag} request failed with status #{stream.status.first}."
    end

    page = JSON.parse(stream.read)
    page_info = page['media']['page_info'] 


    @has_next_page = page_info['has_next_page']
    next_cursor   = page_info['end_cursor']


    loop_through(page['media']['nodes']) 


    return query_tag_instagram(next_cursor) if @has_next_page
  end


end


def loop_through(nodes)
   nodes.each do |node|
    if @active_counter > 50 
      @active_counter = 0
      @has_next_page = false
      break
    end
    save_media(node)
  end
end

def save_media(data)
  media = Media.find_by shortcode: data['code']

  unless media.nil?
    puts "#{data['code']} -  Media already saved"
    @active_counter += 1
    return
  end

  m = Media.new
  m.caption       = data['caption'].to_s
  m.shortcode			= data['code'].to_s
  m.date          = data['date']
  m.dimension_w 		= data['dimensions']['width'].to_i
  m.dimension_h 		= data['dimensions']['height'].to_i
  m.comments_count 	= data['comments']['count'].to_i
  m.likes_count		  = data['likes']['count'].to_i
  m.owner_id 			  = data['owner']['id'].to_s
  m.remote_thumb_src	  = data['thumbnail_src'].to_s
  m.remote_display_src  = data['display_src'].to_s

  m.local_thumb_src	    = get_image("thumb_#{data['code'].to_s}", data['thumbnail_src'].to_s)
  m.local_display_src   = get_image("display_#{data['code'].to_s}", data['display_src'].to_s)
  
  m.instagram_id		    = data['id'].to_s
  m.is_video			      = data['is_video']
  m.location 			      = @active_location_obj
  m.save!
  puts "Saved media #{m.shortcode} - [Hashtag: #{@active_hashtag}] [Location: #{@active_location}]"

	@active_counter += 1
end


def get_image(name, image_url)
  src = "public/media/#{name}.jpg"
  open(src, 'wb') do |file|
    file << open(image_url).read
  end

  return "media/#{name}.jpg"
end


def hashtag_url(hashtag)
  return "https://www.instagram.com/explore/tags/#{hashtag}/"
end


def location_url(location_id)
  return "https://www.instagram.com/explore/locations/#{location_id}/"
end



def query_hashtag_url(hashtag, after_cursor)
  hashencode = %Q{
  ig_hashtag(#{hashtag}) { media.after(#{after_cursor}, 9) {
  count,
  nodes {
    caption,
    code,
    comments {
      count
    },
    date,
    dimensions {
      height,
      width
    },
    display_src,
    id,
    is_video,
    likes {
      count
    },
    owner {
      id
    },
    thumbnail_src,
    video_views
  },
  page_info
}
 }

  }






  return "https://www.instagram.com/query/?q=#{URI.encode(hashencode)}"
end




def query_location_url(location, after_cursor)
  hashencode = %Q{
  ig_location(#{location}) { media.after(#{after_cursor}, 9) {
  count,
  nodes {
    caption,
    code,
    comments {
      count
    },
    date,
    dimensions {
      height,
      width
    },
    display_src,
    id,
    is_video,
    likes {
      count
    },
    owner {
      id
    },
    thumbnail_src,
    video_views
  },
  page_info
}
 }

  }






  return "https://www.instagram.com/query/?q=#{URI.encode(hashencode)}"
end

