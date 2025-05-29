class ParkingSpotsController < ApplicationController

  before_action :set_parking_lot
  before_action :set_parking_spot, only: [:edit, :update]

  def index
    @parking_spots = @parking_lot.parking_spots.includes(:parking_records).order(:spot_type, :identification).page(params[:page]).per(20)
    authorize @parking_spots
    @car_spots = @parking_lot.parking_spots.cars
    @motorcycle_spots = @parking_lot.parking_spots.motorcycles

    spots_car_status = @car_spots.group(:status).count
    @free_car_spots_count = spots_car_status['free'] || 0
    @occupied_car_spots_count = spots_car_status['occupied'] || 0
    @blocked_car_spots_count = spots_car_status['blocked'] || 0

    spots_motorcycle_status = @motorcycle_spots.group(:status).count
    @free_motorcycle_spots_count = spots_motorcycle_status['free'] || 0
    @occupied_motorcycle_spots_count = spots_motorcycle_status['occupied'] || 0
    @blocked_motorcycle_spots_count = spots_motorcycle_status['blocked'] || 0
  end

  def edit
    authorize @parking_spot
  end

  def update
    authorize @parking_spot
    if @parking_spot.update(parking_spot_params)
      redirect_to parking_lot_parking_spots_path(@parking_lot), notice: 'Vaga atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_parking_lot
    @parking_lot = ParkingLot.find(params[:parking_lot_id])
  end

  def set_parking_spot
    @parking_spot = @parking_lot.parking_spots.find(params[:id])
  end

  def parking_spot_params
    params.require(:parking_spot).permit(:status)
  end
end
