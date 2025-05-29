class ParkingRecord < ApplicationRecord

  belongs_to :parking_spot
  belongs_to :parking_lot

  enum payment_status: { pending: 'pending', paid: 'paid' }

  validates :entry_time, presence: true
  validates :plate, presence: true, format: { with: /\A[A-Z]{3}[0-9]{4}\z/, message: "deve seguir o formato ABC1234" }
  validates :parking_spot_id, presence: { message: "é necessário selecionar uma vaga." }

  scope :active, -> { where(exit_time: nil) }
  scope :completed, -> { where.not(exit_time: nil) }
  scope :today, -> { where("entry_time >= ?", Time.zone.now.beginning_of_day) }
  scope :this_month, -> { where("entry_time >= ?", Time.zone.now.beginning_of_month) }

  scope :search_by_plate, ->(plate) {
    where("plate ILIKE ?", "%#{plate}%") if plate.present?
  }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :with_parking_spot, -> { includes(:parking_spot) }

  def vehicle_type
    parking_spot&.spot_type
  end

  def finalize_parking!
    return false if exit_time.present?

    return false unless entry_time.present?

    self.exit_time = Time.current
    duration_in_seconds = (self.exit_time - entry_time).to_i

    self.total_time = duration_in_seconds  # Time.at(duration_in_seconds).utc.strftime('%H:%M:%S')

    self.total_price = parking_lot.calculate_price(vehicle_type, entry_time, self.exit_time)

    if save
      parking_spot.release!
      true
    else
      false
    end
  end

  def elapsed_time
    end_time = exit_time || Time.current
    TimeDifference.between(entry_time, end_time).in_general
  end

  def current_price
    parking_lot.calculate_price(vehicle_type, entry_time, Time.current)
  end

  def mark_as_paid!
    update!(payment_status: 'paid')
  end

  def calculate_temp_data(temp_exit_time = Time.current)
    duration_in_seconds = (temp_exit_time - entry_time).to_i
    temp_total_time = duration_in_seconds
    temp_total_price = parking_lot.calculate_price(vehicle_type, entry_time, temp_exit_time)

    {
      exit_time: temp_exit_time,
      total_time: temp_total_time,
      total_price: temp_total_price
    }
  end

end
