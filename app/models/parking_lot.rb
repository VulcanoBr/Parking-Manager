class ParkingLot < ApplicationRecord

  has_many :parking_spots, dependent: :destroy
  has_many :parking_records, dependent: :destroy

  validates :name, presence: true
  validates :car_spots, :motorcycle_spots, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :opening_time, :closing_time, presence: true
  validates :initial_price_car, :initial_minutes_car, :fraction_price_car, :fraction_minutes_car,
            :initial_price_motorcycle, :initial_minutes_motorcycle, :fraction_price_motorcycle, :fraction_minutes_motorcycle,
            presence: true, numericality: { greater_than: 0 }

  after_create :create_parking_spots

  def occupied_car_spots
    parking_spots.where(spot_type: 'car', status: 'occupied').count
  end

  def occupied_motorcycle_spots
    parking_spots.where(spot_type: 'motorcycle', status: 'occupied').count
  end

  def available_car_spots
    parking_spots.where(spot_type: 'car', status: 'free').count
  end

  def available_motorcycle_spots
    parking_spots.where(spot_type: 'motorcycle', status: 'free').count
  end

  def open?
    current_time = Time.now
    current_time.strftime('%H:%M:%S').between?(opening_time.strftime('%H:%M:%S'), closing_time.strftime('%H:%M:%S'))
  end

  def calculate_price(vehicle_type, entry_time, exit_time)
    # Calcula o preço baseado no tempo estacionado
    duration_in_minutes = ((exit_time - entry_time) / 60).to_i

    if vehicle_type == 'car'
      base_price = initial_price_car
      base_minutes = initial_minutes_car
      fraction_price = fraction_price_car
      fraction_minutes = fraction_minutes_car
    else # motorcycle
      base_price = initial_price_motorcycle
      base_minutes = initial_minutes_motorcycle
      fraction_price = fraction_price_motorcycle
      fraction_minutes = fraction_minutes_motorcycle
    end

    # Preço base para os minutos iniciais
    price = base_price

    # Adiciona frações de tempo adicionais
    if duration_in_minutes > base_minutes
      additional_minutes = duration_in_minutes - base_minutes
      additional_fractions = (additional_minutes.to_f / fraction_minutes).ceil
      price += additional_fractions * fraction_price
    end

    price
  end

  private

  def create_parking_spots
    # Criar vagas de carros
    car_spots.times do |i|
      parking_spots.create!(
        identification: "C#{i+1}",
        spot_type: 'car',
        status: 'free'
      )
    end

    # Criar vagas de motos
    motorcycle_spots.times do |i|
      parking_spots.create!(
        identification: "M#{i+1}",
        spot_type: 'motorcycle',
        status: 'free'
      )
    end
  end

end
