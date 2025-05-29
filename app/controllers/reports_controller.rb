class ReportsController < ApplicationController

  before_action :set_parking_lot

  def index
    authorize :report

    # Calcula tempo médio de permanência hoje
    today = Date.current
    today_records = @parking_lot.parking_records
                      .where(exit_time: today.beginning_of_day..today.end_of_day)
                      .completed

    if today_records.any?
      avg_minutes = today_records.average("EXTRACT(EPOCH FROM (exit_time - entry_time)) / 60").to_i
      @avg_hours = avg_minutes / 60
      @avg_minutes = avg_minutes % 60
    else
      @avg_hours = 0
      @avg_minutes = 0
    end

    # Receita de hoje
    @today_revenue = @parking_lot.parking_records
                      .where(exit_time: today.beginning_of_day..today.end_of_day)
                      .completed
                      .sum(:total_price)

    # Contagem para comparação percentual
    @today_count = @parking_lot.parking_records
                    .where("DATE(exit_time) = ?", Date.today)
                    .completed
                    .count

    @yesterday_count = @parking_lot.parking_records
                        .where("DATE(exit_time) = ?", Date.yesterday)
                        .completed
                        .count

    # Cálculo da porcentagem de mudança
    @percentage_change = if @yesterday_count > 0
                          ((@today_count - @yesterday_count).to_f / @yesterday_count) * 100
                        else
                          0
                        end
  end

  def occupancy
    authorize :report
    @today_records = @parking_lot.parking_records.today
    @car_occupancy = @parking_lot.parking_spots.where(parking_spots: { spot_type: 'car', status: 'occupied' }).count
    @car_blocked = @parking_lot.parking_spots.where(parking_spots: { spot_type: 'car', status: 'blocked' }).count
    @motorcycle_occupancy = @parking_lot.parking_spots.where(parking_spots: { spot_type: 'motorcycle', status: 'occupied' }).count
    @motorcycle_blocked = @parking_lot.parking_spots.where(parking_spots: { spot_type: 'motorcycle', status: 'blocked' }).count

    # Dados para gráfico por hora
    @period = params[:period] || 'daily'
    today = Date.current

    case @period
    when 'daily'
      records = @parking_lot.parking_records.where(entry_time: today.beginning_of_day..today.end_of_day)
      @hourly_data = records.group_by_hour(:entry_time).count
    when 'weekly'
      records = @parking_lot.parking_records.where("entry_time >= ?", 1.week.ago).completed
      @hourly_data = records.group_by_hour(:entry_time).count
    when 'monthly'
      records = @parking_lot.parking_records.where("entry_time >= ?", 1.month.ago).completed
      @hourly_data = records.group_by_hour(:entry_time).count
    end

  end

  def revenue
    authorize :report
    @period = params[:period] || 'daily'
    today = Date.current

    case @period
    when 'daily'
      @records = @parking_lot.parking_records.where(exit_time: today.beginning_of_day..today.end_of_day).completed
      @group_records = @records.group_by_hour(:exit_time).sum(:total_price)
    when 'weekly'
      @records = @parking_lot.parking_records.where("exit_time >= ?", 1.week.ago).completed
      @group_records = @records.group_by_day(:exit_time).sum(:total_price)
    when 'monthly'
      @records = @parking_lot.parking_records.where("exit_time >= ?", 1.month.ago).completed
      @group_records = @records.group_by_day(:exit_time).sum(:total_price)
    end

    @total_revenue = @records.sum(:total_price)
    @paid_count = @records.paid.count
    @pending_count = @records.pending.count

    # Receita por tipo de veículo
    @car_revenue = @records.joins(:parking_spot).where(parking_spots: { spot_type: 'car' }).sum(:total_price)
    @motorcycle_revenue = @records.joins(:parking_spot).where(parking_spots: { spot_type: 'motorcycle' }).sum(:total_price)
  end

  def average_time
    authorize :report
    @records = @parking_lot.parking_records.completed

    if @records.any?
      # Tempo médio de permanência em minutos
      @avg_time_car = @records.joins(:parking_spot)
                      .where(parking_spots: { spot_type: 'car' })
                      .average("EXTRACT(EPOCH FROM (exit_time - entry_time)) / 60")

      @avg_time_motorcycle = @records.joins(:parking_spot)
                            .where(parking_spots: { spot_type: 'motorcycle' })
                            .average("EXTRACT(EPOCH FROM (exit_time - entry_time)) / 60")

      # Tempo médio por hora do dia
      @hourly_avg_time = @records.group_by_hour_of_day(:entry_time)
                          .average("EXTRACT(EPOCH FROM (exit_time - entry_time)) / 60")
    else
      @avg_time_car = 0
      @avg_time_motorcycle = 0
      @hourly_avg_time = {}
    end
  end

  private

  def set_parking_lot
    @parking_lot = ParkingLot.find(params[:parking_lot_id])
  end

end
