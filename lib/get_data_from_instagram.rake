require 'nokogiri'
require 'open-uri'

task :update_from_instagram do
	
end


class Crawler


  def initialize
	@url = "https://www.instagram.com/explore/tags/portomaravilha/"
	@user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.80 Safari/537.36"

  end



  def request_from_instagram
	page = Nokogiri::HTML(open(@url, 'User-Agent' => @user_agent), nil, "UTF-8")
	open('temp/page.html', 'w') do |file|
	  file << page 
	end
	puts "#{Time.now} Page saved..."

  end


  def get_script_data 
	page = Nokogiri::HTML(open('./temp/page.html'))
	page.css("script").each_with_index do |script, index|
	  open("temp/script#{index}.txt", 'w') do |file|
		file << script
	  end
	end
	puts "#{Time.now} Script saved."
  end


end


