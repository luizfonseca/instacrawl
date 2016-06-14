require 'nokogiri'
require 'open-uri'

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.80 Safari/537.36"
@locations = Location.all


task :get_by_hashtag do

	@locations.each do |location|
		list = location.hashtag.split(',')
		list.each do |hashtag|
			find_and_save_media(location.id, { hashtag: hashtag })
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


def find_and_save_media(location_id, options = {})
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
	saved = "./temp/#{page}.html"

	puts "#{Time.now}  - Page #{saved} getting scrapped... "

	page = Nokogiri::HTML(open(saved))
	page.css("script").each_with_index do |script, index|

		if /.window._sharedData$/.match(script.content) 
			open("temp/script-#{page}.txt", 'w') do |file|
				file << script
			end
		end
	end
	puts "#{Time.now} Script saved."

end


def hashtag_url(hashtag)
	return "https://www.instagram.com/explore/tags/#{hashtag}"
end


def location_url(location_id)
	return "https://www.instagram.com/explore/locations/#{location_id}"
end

