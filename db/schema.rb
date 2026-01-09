# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_09_135042) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "amedas_records", force: :cascade do |t|
    t.integer "json_date"
    t.float "pressure"
    t.float "normal_pressure"
    t.float "temp"
    t.integer "humidity"
    t.integer "snow"
    t.integer "wind_direction"
    t.float "wind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "station_number"
    t.index ["station_number"], name: "index_amedas_records_on_station_number"
  end

  create_table "snow_stations", force: :cascade do |t|
    t.integer "station_number", null: false, comment: "観測所番号"
    t.string "prefecture", null: false, comment: "都府県振興局"
    t.string "station_name", null: false, comment: "観測所名"
    t.string "station_name_kana", comment: "カタカナ名"
    t.string "location", comment: "所在地"
    t.float "latitude_degree", comment: "緯度(度)"
    t.float "latitude_minute", comment: "緯度(分)"
    t.float "longitude_degree", comment: "経度(度)"
    t.float "longitude_minute", comment: "経度  (分)"
    t.decimal "latitude", precision: 10, scale: 7, comment: "緯度(10進数)"
    t.decimal "longitude", precision: 10, scale: 7, comment: "経度(10進数)"
    t.string "station_type", comment: "種類"
    t.integer "elevation_meters", comment: "海面上の高さ(ｍ)"
    t.date "observation_start_date", comment: "観測開始年月日"
    t.text "note", comment: "備考"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["station_number"], name: "index_snow_stations_on_station_number", unique: true
  end

  create_table "user_statuses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", default: "名無しの雪だるま"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "station_number"
    t.index ["station_number"], name: "index_user_statuses_on_station_number"
    t.index ["user_id"], name: "index_user_statuses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "amedas_records", "snow_stations", column: "station_number", primary_key: "station_number"
  add_foreign_key "user_statuses", "snow_stations", column: "station_number", primary_key: "station_number"
  add_foreign_key "user_statuses", "users"
end
