class ParkingRecordsController < ApplicationController

  before_action :set_parking_lot
  before_action :set_parking_record, only: [:show, :edit, :checkout, :payment, :mark_as_paid ]

  def index
    authorize ParkingRecord

    @parking_records = @parking_lot.parking_records
                                  .with_parking_spot
                                  .search_by_plate(params[:search])
                                  .recent_first
                                  .page(params[:page])
                                  .per(10)
  end

  def show
    authorize ParkingRecord
  end

  def new
    @parking_record = @parking_lot.parking_records.new
    authorize ParkingRecord
    @available_spots = available_spots_by_type
    @available_car_spots = @available_spots[:car]
    @available_motorcycle_spots = @available_spots[:motorcycle]

    @spots_count = spots_count_by_type
  end

  def next_available_spot
    authorize ParkingRecord
    vehicle_type = params[:vehicle_type]

    case vehicle_type
    when 'car'
      spot = @parking_lot.parking_spots.cars.available.order(:identification).first
      count = @parking_lot.parking_spots.cars.available.count
    when 'motorcycle'
      spot = @parking_lot.parking_spots.motorcycles.available.order(:identification).first
      count = @parking_lot.parking_spots.motorcycles.available.count
    else
      render json: { error: 'Tipo de veículo inválido' }, status: :bad_request
      return
    end

    if spot
      render json: {
        success: true,
        spot: {
          id: spot.id,
          identification: spot.identification
        },
        available_count: count,
        message: "Vaga #{spot.identification} será reservada"
      }
    else
      render json: {
        success: false,
        available_count: 0,
        message: "Não há vagas disponíveis para #{vehicle_type == 'car' ? 'carros' : 'motocicletas'}"
      }
    end
  end

  def edit
    authorize ParkingRecord
  end

  def create
    @parking_record = @parking_lot.parking_records.new(parking_record_params)
    authorize ParkingRecord
    @parking_record.entry_time = Time.current

    if @parking_record.save
      # Ocupa a vaga
      @parking_record.parking_spot.occupy!
      redirect_to parking_lot_parking_record_path(@parking_lot, @parking_record), notice: 'Registro de entrada criado com sucesso.'
    else
      @available_spots = available_spots_by_type
      @spots_count = spots_count_by_type
      render :new, status: :unprocessable_entity
    end
  end

  def checkout
    authorize ParkingRecord

    @temp_exit_time = Time.current
    @temp_total_time = calculate_temp_total_time(@parking_record.entry_time, @temp_exit_time)
    @temp_total_price = @parking_lot.calculate_price(@parking_record.vehicle_type, @parking_record.entry_time, @temp_exit_time)

    redirect_to payment_parking_lot_parking_record_path(@parking_lot, @parking_record,
                                                        temp_exit_time: @temp_exit_time,
                                                        temp_total_time: @temp_total_time,
                                                        temp_total_price: @temp_total_price)
  end

  def payment
    authorize ParkingRecord

    @temp_exit_time = params[:temp_exit_time] ? Time.parse(params[:temp_exit_time]) : Time.current
    @temp_total_time = params[:temp_total_time].to_i || calculate_temp_total_time(@parking_record.entry_time, @temp_exit_time)
    @temp_total_price = params[:temp_total_price] || @parking_lot.calculate_price(@parking_record.vehicle_type, @parking_record.entry_time, @temp_exit_time)
  end

  def mark_as_paid
    authorize ParkingRecord

    if @parking_record.finalize_parking!
      @parking_record.mark_as_paid!
      redirect_to parking_lot_parking_records_path(@parking_lot),
                  notice: 'Pagamento confirmado e veículo liberado com sucesso!'
    else
      redirect_to payment_parking_lot_parking_record_path(@parking_lot, @parking_record),
                  alert: 'Erro ao processar o pagamento.'
    end
  end

  private

  def set_parking_lot
    @parking_lot = ParkingLot.find(params[:parking_lot_id])
  end

  def set_parking_record
    @parking_record = @parking_lot.parking_records.find(params[:id])
  end

  def parking_record_params
    params.require(:parking_record).permit(:plate, :vehicle_type, :parking_spot_id)
  end

  def calculate_temp_total_time(entry_time, exit_time)
    duration_in_seconds = (exit_time - entry_time).to_i
  end

  def available_spots_by_type
    {
      car: @parking_lot.parking_spots.cars.available.order(:identification),
      motorcycle: @parking_lot.parking_spots.motorcycles.available.order(:identification)
    }
  end

  def spots_count_by_type
    {
      car: @parking_lot.parking_spots.cars.available.count,
      motorcycle: @parking_lot.parking_spots.motorcycles.available.count
    }
  end

  def set_first_available_spots
    @first_available_car_spot = @parking_lot.parking_spots.cars.available.order(:identification).first
    @first_available_motorcycle_spot = @parking_lot.parking_spots.motorcycles.available.order(:identification).first
  end

  def find_first_available_spot_for_type(vehicle_type)
    if vehicle_type == 'car'
      @parking_lot.parking_spots.cars.available.order(:identification).first
    elsif vehicle_type == 'motorcycle'
      @parking_lot.parking_spots.motorcycles.available.order(:identification).first
    else
      nil
    end
  end

end
