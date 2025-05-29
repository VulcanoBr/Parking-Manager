class CreateParkingRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :parking_records do |t|
      t.datetime :entry_time, null: false
      t.datetime :exit_time
      t.integer :total_time
      t.decimal :total_price, precision: 10, scale: 2
      t.string :payment_status, null: false, default: 'pending'
      t.string :vehicle_type, null: false
      t.string :plate, null: false
      t.references :parking_spot, null: false, foreign_key: true
      t.references :parking_lot, null: false, foreign_key: true

      t.timestamps
    end
    add_index :parking_records, :plate
    add_index :parking_records, :entry_time
    add_index :parking_records, :payment_status
  end
end
