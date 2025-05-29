class ParkingLotsController < ApplicationController

  before_action :set_parking_lot, only: [:show, :edit, :update, :destroy]

  def index
    @parking_lots = ParkingLot.all.page(params[:page]).per(10)
    authorize @parking_lots
  end

  def show
    authorize @parking_lot
    @car_spots = @parking_lot.parking_spots.cars.order(:identification)
    @motorcycle_spots = @parking_lot.parking_spots.motorcycles.order(:identification)
    @active_records = @parking_lot.parking_records.active.includes(:parking_spot)

    @car_spots_collection = @parking_lot.parking_spots.cars  #where(spot_type: 'car')
    @total_car_spots_defined = @parking_lot.car_spots

    if @total_car_spots_defined > 0
      spots_by_status = @car_spots_collection.group(:status).count

      @free_car_spots_count = spots_by_status['free'] || 0
      @occupied_car_spots_count = spots_by_status['occupied'] || 0
      @blocked_car_spots_count = spots_by_status['blocked'] || 0
    else
      @free_car_spots_count = 0
      @occupied_car_spots_count = 0
      @blocked_car_spots_count = 0
    end

    @motorcycle_spots_collection = @parking_lot.parking_spots.motorcycles   # where(spot_type: 'motorcycle')
    @total_motorcycle_spots_defined = @parking_lot.motorcycle_spots

    if @total_motorcycle_spots_defined > 0
      spots_mt_status = @motorcycle_spots_collection.group(:status).count

      @free_motorcycle_spots_count = spots_mt_status['free'] || 0
      @occupied_motorcycle_spots_count = spots_mt_status['occupied'] || 0
      @blocked_motorcycle_spots_count = spots_mt_status['blocked'] || 0
    else
      @free_motorcycle_spots_count = 0
      @occupied_motorcycle_spots_count = 0
      @blocked_motorcycle_spots_count = 0
    end
  end

  def new
    @parking_lot = ParkingLot.new
    authorize @parking_lot
  end

  def create
    @parking_lot = ParkingLot.new(parking_lot_params)
    authorize @parking_lot
    if @parking_lot.save
      redirect_to @parking_lot, notice: 'Estacionamento criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @parking_lot
  end

  def update
    authorize @parking_lot
    if @parking_lot.update(parking_lot_params)
      redirect_to @parking_lot, notice: 'Estacionamento atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @parking_lot
    @parking_lot.destroy
    redirect_to parking_lots_url, notice: 'Estacionamento excluído com sucesso.'
  end

  private

  def set_parking_lot
    @parking_lot = ParkingLot.find(params[:id])
  end

  def parking_lot_params
    params.require(:parking_lot).permit(
      :name, :car_spots, :motorcycle_spots, :opening_time, :closing_time,
      :initial_price_car, :initial_minutes_car, :fraction_price_car, :fraction_minutes_car,
      :initial_price_motorcycle, :initial_minutes_motorcycle, :fraction_price_motorcycle, :fraction_minutes_motorcycle
    )
  end

end
