class CreateLocations < ActiveRecord::Migration
  def change
	  create_table :locations do |t|
		t.string :name, null: false, default: ''
		t.string :hashtag, null: false, default: ''
		t.string :lat, null: false, default: ''
		t.string :lng, null: false, default: ''
	  end
  end
end
