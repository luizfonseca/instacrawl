class ChangeIntegerMediaColumns < ActiveRecord::Migration
  def change
	  change_column :medias, :owner_id, :string, default: '0', null: false
  end
end
