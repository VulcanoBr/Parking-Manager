class CreateParkingLots < ActiveRecord::Migration[7.2]
  def change
    create_table :parking_lots do |t|
      t.string :name, null: false
      t.integer :car_spots, null: false, default: 0
      t.integer :motorcycle_spots, null: false, default: 0
      t.time :opening_time, null: false
      t.time :closing_time, null: false
      t.decimal :initial_price_car, precision: 10, scale: 2, null: false
      t.integer :initial_minutes_car, null: false
      t.decimal :fraction_price_car, precision: 10, scale: 2, null: false
      t.integer :fraction_minutes_car, null: false
      t.decimal :initial_price_motorcycle, precision: 10, scale: 2, null: false
      t.integer :initial_minutes_motorcycle, null: false
      t.decimal :fraction_price_motorcycle, precision: 10, scale: 2, null: false
      t.integer :fraction_minutes_motorcycle, null: false

      t.timestamps
    end
  end
end
