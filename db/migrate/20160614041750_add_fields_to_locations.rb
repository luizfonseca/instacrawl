class AddFieldsToLocations < ActiveRecord::Migration
  def change
	  add_column :locations, :address, :string, null: false, default: ''
	  add_column :locations, :instagram_id, :integer, null: false, default: 0
  end
end
