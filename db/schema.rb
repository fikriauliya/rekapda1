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

ActiveRecord::Schema.define(version: 20140715044635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fetch_statuses", force: true do |t|
    t.integer  "to_be_updated_index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kabupatens", id: false, force: true do |t|
    t.integer "id"
    t.string  "name"
  end

  create_table "kecamatans", id: false, force: true do |t|
    t.integer "id"
    t.string  "name"
  end

  create_table "locations", force: true do |t|
    t.integer  "province_id"
    t.integer  "kabupaten_id"
    t.integer  "kecamatan_id"
    t.integer  "prabowo_count",   default: 0
    t.integer  "jokowi_count",    default: 0
    t.datetime "last_fetched_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "provinces", id: false, force: true do |t|
    t.integer "id"
    t.string  "name"
  end

  create_table "votes", force: true do |t|
    t.integer  "grand_parent_id"
    t.integer  "parent_id"
    t.integer  "prabowo_count"
    t.integer  "jokowi_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
