

namespace :dev do
  desc "Reset the parking database"
  task reset_parking: :environment do
    system("rails db:drop")
    system("rails db:create")
    system("rails db:migrate")
    system("rails dev:setup_parking_lot")
    system("rails dev:create_parking_spots")
    system("rails dev:generate_parking_records")
  end

  desc "Setup complete parking system"
  task setup_parking: :environment do
    system("rails dev:setup_parking_lot")
    system("rails dev:create_parking_spots")
    system("rails dev:generate_parking_records")
  end

  desc "Create Vulcan Parking lot"
  task setup_parking_lot: :environment do
    show_spinner("Creating Vulcan Parking lot") { create_parking_lot }
  end

  desc "Create parking spots"
  task create_parking_spots: :environment do
    show_spinner("Creating parking spots") { create_parking_spots }
  end

  desc "Generate parking records"
  task generate_parking_records: :environment do
    show_spinner("Generating 3000 parking records") { generate_parking_records }
  end

  desc "Show parking statistics"
  task parking_stats: :environment do
    show_parking_statistics
  end

  desc "Clean parking data"
  task clean_parking: :environment do
    show_spinner("Cleaning parking data") { clean_parking_data }
  end

  desc "Debug parking record generation"
  task debug_parking: :environment do
    debug_parking_generation
  end

  private

  # Método para criar o estacionamento
  def create_parking_lot
    # Verificar se já existe
    existing_lot = ParkingLot.find_by(name: "Vulcan parking")
    if existing_lot
      puts "Vulcan parking já existe. Pulando criação..."
      return existing_lot
    end

    parking_lot = ParkingLot.create!(
      name: "Vulcan parking",
      car_spots: 25,
      motorcycle_spots: 10,
      opening_time: Time.parse("07:00"),
      closing_time: Time.parse("19:00"),
      initial_price_car: 10.0,
      initial_minutes_car: 30,
      fraction_price_car: 5.0,
      fraction_minutes_car: 30,
      initial_price_motorcycle: 10.0,
      initial_minutes_motorcycle: 30,
      fraction_price_motorcycle: 5.0,
      fraction_minutes_motorcycle: 30
    )

    puts "Estacionamento criado: #{parking_lot.name}"
    parking_lot
  end

  # Método para criar vagas
  def create_parking_spots
    parking_lot = ParkingLot.find_by(name: "Vulcan parking")
    unless parking_lot
      puts "Estacionamento não encontrado. Execute primeiro: rails dev:setup_parking_lot"
      return
    end

    # Limpar vagas existentes se necessário
    parking_lot.parking_spots.destroy_all if parking_lot.parking_spots.any?

    # Criar vagas de carros
    parking_lot.car_spots.times do |i|
      parking_lot.parking_spots.create!(
        identification: "C#{i+1}",
        spot_type: 'car',
        status: 'free'
      )
    end

    # Criar vagas de motos
    parking_lot.motorcycle_spots.times do |i|
      parking_lot.parking_spots.create!(
        identification: "M#{i+1}",
        spot_type: 'motorcycle',
        status: 'free'
      )
    end

    puts "Criadas #{parking_lot.parking_spots.count} vagas"
  end

  # Método para gerar registros de estacionamento
  def generate_parking_records
    parking_lot = ParkingLot.find_by(name: "Vulcan parking")
    unless parking_lot
      puts "Estacionamento não encontrado. Execute primeiro: rails dev:setup_parking_lot"
      return
    end

    if parking_lot.parking_spots.empty?
      puts "Nenhuma vaga encontrada. Execute primeiro: rails dev:create_parking_spots"
      return
    end

    # Limpar registros existentes
    ParkingRecord.destroy_all

    parking_spots = parking_lot.parking_spots.to_a
    existing_records = []
    records_created = 0
    failed_attempts = 0

    # Período de 30 dias
    end_date = Date.current - 1.day
    start_date = end_date - 30.days

    puts "Gerando registros para período: #{start_date.strftime('%d/%m/%Y')} a #{end_date.strftime('%d/%m/%Y')}"
    puts "Total de vagas: #{parking_spots.count}"

    3000.times do |i|
      attempts = 0
      max_attempts = 20
      success = false

      while attempts < max_attempts && !success
        attempts += 1

        begin
          # Data aleatória dentro do período
          days_offset = rand(0..30)
          random_date = start_date + days_offset.days

          # Hora de entrada aleatória (mais flexível)
          opening_hour = parking_lot.opening_time.hour
          closing_hour = parking_lot.closing_time.hour

          # Garantir que há tempo suficiente para permanência mínima
          max_entry_hour = closing_hour - 1
          entry_hour = rand(opening_hour..max_entry_hour)
          entry_minute = rand(0..59)

          entry_time = random_date.beginning_of_day + entry_hour.hours + entry_minute.minutes

          # Garantir que não seja no futuro
          if entry_time > Time.current
            entry_time = Time.current - rand(1.hour..48.hours)
          end

          # Duração mais realística (15 minutos a 12 horas na maioria dos casos)
          if rand(1..10) <= 8  # 80% dos casos: permanência normal
            duration_minutes = rand(15..720) # 15 min a 12 horas
          else # 20% dos casos: permanência longa
            duration_minutes = rand(720..(24*60)) # 12 a 24 horas
          end

          exit_time = entry_time + duration_minutes.minutes

          # Garantir limite de 2 dias
          max_exit_time = entry_time + 2.days
          exit_time = [exit_time, max_exit_time].min
          exit_time = [exit_time, Time.current].min

          # Garantir duração mínima
          if (exit_time - entry_time) < 10.minutes
            exit_time = entry_time + 10.minutes
          end

          # Escolher vaga aleatória
          spot = parking_spots.sample
          vehicle_type = spot.spot_type

          # Verificar disponibilidade (algoritmo simplificado para reduzir conflitos)
          conflict = existing_records.any? do |record|
            record.parking_spot_id == spot.id &&
            !(exit_time <= record.entry_time || entry_time >= record.exit_time)
          end

          if conflict
            # Tentar outra vaga se houver conflito
            next if attempts < max_attempts
            raise "Conflito de horário após #{attempts} tentativas"
          end

          # Calcular tempo e preço
          total_time = (exit_time - entry_time).to_i
          total_price = calculate_parking_price(parking_lot, vehicle_type, entry_time, exit_time)

          # Criar registro
          record = ParkingRecord.create!(
            entry_time: entry_time,
            exit_time: exit_time,
            total_time: total_time,
            total_price: total_price,
            payment_status: 'paid',
            vehicle_type: vehicle_type,
            plate: generate_random_plate,
            parking_spot_id: spot.id,
            parking_lot_id: parking_lot.id
          )

          existing_records << record
          records_created += 1
          success = true

          # Progresso a cada 500 registros
          if (records_created % 500) == 0
            puts "Progresso: #{records_created} registros criados..."
          end

        rescue => e
          # Log do erro para debug
          if attempts >= max_attempts
            failed_attempts += 1
            puts "Erro no registro #{i + 1} após #{attempts} tentativas: #{e.message}" if failed_attempts <= 5
          end
        end
      end
    end

    puts "Criados #{records_created} registros de estacionamento!"
    puts "Falhas: #{failed_attempts}" if failed_attempts > 0
  end

  # Método para calcular preço
  def calculate_parking_price(parking_lot, vehicle_type, entry_time, exit_time)
    duration_in_minutes = ((exit_time - entry_time) / 60).to_i

    if vehicle_type == 'car'
      base_price = parking_lot.initial_price_car
      base_minutes = parking_lot.initial_minutes_car
      fraction_price = parking_lot.fraction_price_car
      fraction_minutes = parking_lot.fraction_minutes_car
    else # motorcycle
      base_price = parking_lot.initial_price_motorcycle
      base_minutes = parking_lot.initial_minutes_motorcycle
      fraction_price = parking_lot.fraction_price_motorcycle
      fraction_minutes = parking_lot.fraction_minutes_motorcycle
    end

    # Preço base
    price = base_price

    # Frações adicionais
    if duration_in_minutes > base_minutes
      additional_minutes = duration_in_minutes - base_minutes
      additional_fractions = (additional_minutes.to_f / fraction_minutes).ceil
      price += additional_fractions * fraction_price
    end

    price
  end

  # Método para gerar placa aleatória
  def generate_random_plate
    letters = ('A'..'Z').to_a
    numbers = (0..9).to_a

    plate = ""
    3.times { plate += letters.sample }
    4.times { plate += numbers.sample.to_s }

    plate
  end

  # Método para verificar disponibilidade da vaga
  def spot_available?(spot, entry_time, exit_time, existing_records)
    existing_records.none? do |record|
      record.parking_spot_id == spot.id &&
      !(exit_time <= record.entry_time || entry_time >= record.exit_time)
    end
  end

  # Método para limpar dados
  def clean_parking_data
    ParkingRecord.destroy_all
    ParkingSpot.destroy_all
    ParkingLot.destroy_all
    puts "Dados de estacionamento removidos com sucesso!"
  end

  # Método para mostrar estatísticas
  def show_parking_statistics
    parking_lot = ParkingLot.find_by(name: "Vulcan parking")

    unless parking_lot
      puts "Estacionamento não encontrado!"
      return
    end

    puts "\n" + "="*50
    puts "ESTATÍSTICAS DO ESTACIONAMENTO"
    puts "="*50
    puts "Nome: #{parking_lot.name}"
    puts "Horário: #{parking_lot.opening_time.strftime('%H:%M')} às #{parking_lot.closing_time.strftime('%H:%M')}"
    puts "Total de vagas: #{parking_lot.parking_spots.count}"
    puts "├── Vagas de carros: #{parking_lot.parking_spots.where(spot_type: 'car').count}"
    puts "└── Vagas de motos: #{parking_lot.parking_spots.where(spot_type: 'motorcycle').count}"

    total_records = ParkingRecord.where(parking_lot: parking_lot).count
    puts "\nRegistros de estacionamento: #{total_records}"

    if total_records > 0
      car_records = ParkingRecord.joins(:parking_spot)
                                .where(parking_lot: parking_lot, parking_spots: { spot_type: 'car' })

      motorcycle_records = ParkingRecord.joins(:parking_spot)
                                       .where(parking_lot: parking_lot, parking_spots: { spot_type: 'motorcycle' })

      puts "├── Registros de carros: #{car_records.count}"
      puts "└── Registros de motos: #{motorcycle_records.count}"

      total_revenue = ParkingRecord.where(parking_lot: parking_lot).sum(:total_price)
      puts "\nReceita total: R$ #{total_revenue.round(2)}"

      if car_records.any?
        car_revenue = car_records.sum(:total_price)
        puts "├── Receita carros: R$ #{car_revenue.round(2)}"
      end

      if motorcycle_records.any?
        motorcycle_revenue = motorcycle_records.sum(:total_price)
        puts "└── Receita motos: R$ #{motorcycle_revenue.round(2)}"
      end

      # Estatísticas de tempo
      avg_duration = ParkingRecord.where(parking_lot: parking_lot).average(:total_time)
      if avg_duration
        avg_hours = (avg_duration / 3600).round(1)
        puts "\nTempo médio de permanência: #{avg_hours} horas"
      end

      # Período dos registros
      first_record = ParkingRecord.where(parking_lot: parking_lot).minimum(:entry_time)
      last_record = ParkingRecord.where(parking_lot: parking_lot).maximum(:exit_time)

      if first_record && last_record
        puts "Período dos registros: #{first_record.strftime('%d/%m/%Y')} a #{last_record.strftime('%d/%m/%Y')}"
      end
    end

    puts "="*50
  end

  # Método para debug
  def debug_parking_generation
    parking_lot = ParkingLot.find_by(name: "Vulcan parking")

    puts "\n=== DEBUG PARKING GENERATION ==="
    puts "Estacionamento encontrado: #{parking_lot ? 'SIM' : 'NÃO'}"
    return unless parking_lot

    puts "Nome: #{parking_lot.name}"
    puts "Horário: #{parking_lot.opening_time} às #{parking_lot.closing_time}"
    puts "Vagas totais: #{parking_lot.parking_spots.count}"
    puts "Vagas de carro: #{parking_lot.parking_spots.where(spot_type: 'car').count}"
    puts "Vagas de moto: #{parking_lot.parking_spots.where(spot_type: 'motorcycle').count}"

    # Teste de criação de um registro
    puts "\n--- Testando criação de 1 registro ---"

    begin
      spot = parking_lot.parking_spots.first
      puts "Vaga escolhida: #{spot.identification} (#{spot.type})"

      # Data/hora simples para teste
      entry_time = 1.day.ago.beginning_of_day + 10.hours
      exit_time = entry_time + 2.hours

      puts "Entrada: #{entry_time}"
      puts "Saída: #{exit_time}"

      total_time = (exit_time - entry_time).to_i
      total_price = calculate_parking_price(parking_lot, spot.spot_type, entry_time, exit_time)

      puts "Tempo total: #{total_time} segundos"
      puts "Preço calculado: R$ #{total_price}"

      # Tentar criar o registro
      record = ParkingRecord.create!(
        entry_time: entry_time,
        exit_time: exit_time,
        total_time: total_time,
        total_price: total_price,
        payment_status: 'paid',
        plate: generate_random_plate,
        parking_spot_id: spot.id,
        parking_lot_id: parking_lot.id
      )

      puts "Registro criado com sucesso! ID: #{record.id}"
      puts "Placa: #{record.plate}"

      # Limpar o registro de teste
      record.destroy
      puts "Registro de teste removido."

    rescue => e
      puts "ERRO ao criar registro: #{e.message}"
      puts "Backtrace: #{e.backtrace.first(3).join('\n')}"
    end

    puts "=== FIM DEBUG ==="
  end

  # Método para spinner (mesmo do seu exemplo)
  def show_spinner(msg_start, msg_end = "Done!")
    if defined?(TTY::Spinner)
      spinner = TTY::Spinner.new("[:spinner] #{msg_start}")
      spinner.auto_spin
      yield
      spinner.success("(#{msg_end})")
    else
      puts "#{msg_start}..."
      yield
      puts "#{msg_end}"
    end
  end
end
