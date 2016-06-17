class ChangeLocationsInstagram < ActiveRecord::Migration
  def change
    rename_column :locations, :instagram_id, :instagram_location_id
  end
end
