class DashboardController < ApplicationController

  before_action :require_admin, only: [:index]

  def index
    @parking_lots = ParkingLot.all
    authorize :dashboard, :index?

    if @parking_lots.any?
      @total_car_spots = @parking_lots.sum(:car_spots)
      @total_motorcycle_spots = @parking_lots.sum(:motorcycle_spots)

      # Busca todos os dados ocupados de uma vez (reutilizável)
      occupied_spots = ParkingSpot.where(status: 'occupied')
                                  .group(:parking_lot_id, :spot_type)
                                  .count

      # Calcula totais gerais a partir dos dados já buscados
      @occupied_car_spots = occupied_spots.select { |key, _| key[1] == 'car' }.values.sum
      @occupied_motorcycle_spots = occupied_spots.select { |key, _| key[1] == 'motorcycle' }.values.sum

      # Cálculo da porcentagem de ocupação de carros
      @car_occupancy_percentage = @total_car_spots > 0 ? (@occupied_car_spots.to_f / @total_car_spots * 100).to_i : 0

      # Cálculo da porcentagem de ocupação de motos
      @motorcycle_occupancy_percentage = @total_motorcycle_spots > 0 ? (@occupied_motorcycle_spots.to_f / @total_motorcycle_spots * 100).to_i : 0

      # Registros ativos
      @active_records = ParkingRecord.active.includes(:parking_spot, :parking_lot).order(entry_time: :desc)

      # Estatísticas do dia
      @today_entries = ParkingRecord.where("entry_time >= ?", Date.today.beginning_of_day).count
      @today_exits = ParkingRecord.where("exit_time >= ?", Date.today.beginning_of_day).count
      @today_revenue = ParkingRecord.where("exit_time >= ?", Date.today.beginning_of_day).sum(:total_price)

      # Dados específicos por estacionamento (reutiliza os dados já buscados)
      @parking_lots_data = calculate_parking_lots_data(occupied_spots)
    else
      @total_car_spots = 0
      @total_motorcycle_spots = 0
      @occupied_car_spots = 0
      @car_occupancy_percentage = 0
      @motorcycle_occupancy_percentage = 0
      @occupied_motorcycle_spots = 0
      @active_records = []
      @today_entries = 0
      @today_exits = 0
      @today_revenue = 0
      @parking_lots_data = {}
    end
  end

  private

  def calculate_parking_lots_data(occupied_spots)
    parking_lots_data = {}

    @parking_lots.each do |parking_lot|
      car_occupied = occupied_spots[[parking_lot.id, 'car']] || 0
      motorcycle_occupied = occupied_spots[[parking_lot.id, 'motorcycle']] || 0
      total_spots = parking_lot.car_spots + parking_lot.motorcycle_spots
      total_occupied = car_occupied + motorcycle_occupied
      occupancy_percentage = total_spots > 0 ? (total_occupied.to_f / total_spots * 100).to_i : 0

      parking_lots_data[parking_lot.id] = {
        car_occupied: car_occupied,
        motorcycle_occupied: motorcycle_occupied,
        total_spots: total_spots,
        total_occupied: total_occupied,
        occupancy_percentage: occupancy_percentage
      }
    end

    parking_lots_data
  end

end
