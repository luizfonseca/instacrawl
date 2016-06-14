require 'open-uri'
require 'json'


task :update_poi do
	@json = JSON.load(File.read('./test/poi.json'))
	@hash = @json["data"]["locales"]["pt"]["AppProjectPoi"]
	puts @hash.first['rowID']

end





