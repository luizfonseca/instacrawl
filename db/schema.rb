# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160617160658) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.string  "name",                  default: "", null: false
    t.string  "hashtag",               default: "", null: false
    t.string  "lat",                   default: "", null: false
    t.string  "lng",                   default: "", null: false
    t.string  "address",               default: "", null: false
    t.integer "instagram_location_id", default: 0,  null: false
  end

  create_table "medias", force: :cascade do |t|
    t.text    "caption",            default: "",    null: false
    t.string  "shortcode",          default: "",    null: false
    t.integer "dimension_w",        default: 1080,  null: false
    t.integer "dimension_h",        default: 1350,  null: false
    t.integer "likes_count",        default: 0,     null: false
    t.integer "comments_count",     default: 0,     null: false
    t.string  "owner_id",           default: "0",   null: false
    t.boolean "is_video",           default: false, null: false
    t.string  "instagram_id",       default: "0",   null: false
    t.string  "remote_thumb_src",   default: "",    null: false
    t.string  "remote_display_src", default: "",    null: false
    t.string  "local_thumb_src",    default: "",    null: false
    t.string  "local_display_src",  default: "",    null: false
    t.integer "date",               default: 0,     null: false
    t.integer "location_id",                        null: false
  end

end
