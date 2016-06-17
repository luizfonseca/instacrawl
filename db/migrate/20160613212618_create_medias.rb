class CreateMedias < ActiveRecord::Migration
  def change
	create_table :medias do |t|

		t.text :caption, default: '', null: false
		t.string :shortcode, default: '', null: false
		t.integer :dimension_w, default: 1080, null: false
		t.integer :dimension_h, default: 1350, null: false

		t.integer :likes_count, default: 0, null: false
		t.integer :comments_count, default: 0, null: false

		t.integer :owner_id, default: 1, null: false
		t.boolean :is_video, default: false, null: false

		t.string :instagram_id, default: '0', null: false

		t.string :remote_thumb_src, default: '', null: false
		t.string :remote_display_src, default: '', null: false

		t.string :local_thumb_src, default: '', null: false
		t.string :local_display_src, default: '', null: false

		t.integer :date, default: 0, null: false


		t.integer :location_id, null: false
	end
  end
end
