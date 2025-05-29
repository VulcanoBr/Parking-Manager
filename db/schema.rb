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

ActiveRecord::Schema[7.2].define(version: 2025_05_25_003805) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "parking_lots", force: :cascade do |t|
    t.string "name", null: false
    t.integer "car_spots", default: 0, null: false
    t.integer "motorcycle_spots", default: 0, null: false
    t.time "opening_time", null: false
    t.time "closing_time", null: false
    t.decimal "initial_price_car", precision: 10, scale: 2, null: false
    t.integer "initial_minutes_car", null: false
    t.decimal "fraction_price_car", precision: 10, scale: 2, null: false
    t.integer "fraction_minutes_car", null: false
    t.decimal "initial_price_motorcycle", precision: 10, scale: 2, null: false
    t.integer "initial_minutes_motorcycle", null: false
    t.decimal "fraction_price_motorcycle", precision: 10, scale: 2, null: false
    t.integer "fraction_minutes_motorcycle", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parking_records", force: :cascade do |t|
    t.datetime "entry_time", null: false
    t.datetime "exit_time"
    t.integer "total_time"
    t.decimal "total_price", precision: 10, scale: 2
    t.string "payment_status", default: "pending", null: false
    t.string "vehicle_type", null: false
    t.string "plate", null: false
    t.bigint "parking_spot_id", null: false
    t.bigint "parking_lot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_time"], name: "index_parking_records_on_entry_time"
    t.index ["parking_lot_id"], name: "index_parking_records_on_parking_lot_id"
    t.index ["parking_spot_id"], name: "index_parking_records_on_parking_spot_id"
    t.index ["payment_status"], name: "index_parking_records_on_payment_status"
    t.index ["plate"], name: "index_parking_records_on_plate"
  end

  create_table "parking_spots", force: :cascade do |t|
    t.string "identification", null: false
    t.string "spot_type", null: false
    t.string "status", default: "free", null: false
    t.bigint "parking_lot_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parking_lot_id", "identification"], name: "index_parking_spots_on_parking_lot_id_and_identification", unique: true
    t.index ["parking_lot_id"], name: "index_parking_spots_on_parking_lot_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "user_type", default: "manager", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_type"], name: "index_users_on_user_type"
  end

  add_foreign_key "parking_records", "parking_lots"
  add_foreign_key "parking_records", "parking_spots"
  add_foreign_key "parking_spots", "parking_lots"
end
