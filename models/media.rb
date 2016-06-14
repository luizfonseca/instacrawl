class Media < ActiveRecord::Base
	self.table_name = "medias" 

	belongs_to :location
	validates_presence_of :location

	#def as_json(options={})
		#return {

		#}.merge(options)
		
	#end

end

