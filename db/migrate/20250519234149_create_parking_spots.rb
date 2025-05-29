class CreateParkingSpots < ActiveRecord::Migration[7.2]
  def change
    create_table :parking_spots do |t|
      t.string :identification, null: false
      t.string :spot_type, null: false
      t.string :status, null: false, default: 'free'
      t.references :parking_lot, null: false, foreign_key: true

      t.timestamps
    end
    add_index :parking_spots, [:parking_lot_id, :identification], unique: true
  end
end
