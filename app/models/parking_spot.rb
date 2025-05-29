class ParkingSpot < ApplicationRecord

  belongs_to :parking_lot
  has_many :parking_records

  enum spot_type: { car: 'car', motorcycle: 'motorcycle' }
  enum status: { free: 'free', occupied: 'occupied', blocked: 'blocked' }

  validates :identification, presence: true, uniqueness: { scope: :parking_lot_id }
  validates :spot_type, :status, presence: true

  scope :available, -> { where(status: 'free') }
  scope :cars, -> { where(spot_type: 'car') }
  scope :motorcycles, -> { where(spot_type: 'motorcycle') }

  def occupy!
    update!(status: 'occupied')
  end

  def release!
    update!(status: 'free')
  end

  def block!
    update!(status: 'blocked')
  end

  def available?
    free?
  end

  def current_vehicle_plate
    return nil unless occupied?
    parking_records.active.first&.plate
  end

  def current_record
    return nil unless occupied?
    parking_records.active.first
  end

end
