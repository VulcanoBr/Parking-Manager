module ParkingRecordsHelper

  def time_elapsed(entry_time)
    return "Indisponível" if entry_time.nil?

    seconds_diff = (Time.current - entry_time).to_i

    days = seconds_diff / 86400
    hours = (seconds_diff % 86400) / 3600
    minutes = (seconds_diff % 3600) / 60
    seconds = seconds_diff % 60

    if days > 0
      "#{days}d #{hours}h #{minutes}m #{seconds}s"
    elsif hours > 0
      "#{hours}h #{minutes}m #{seconds}s"
    elsif minutes > 0
      "#{minutes}m #{seconds}s"
    else
      "#{seconds}s"
    end
  end

  def format_time_object_as_hours_and_minutes(time_object)
    return "-hs -min" if time_object.nil? || !time_object.respond_to?(:hour) # Ou como preferir tratar nulos

    hours = time_object.hour
    minutes = time_object.min

    "#{hours}hs #{minutes}min"
  end

  def format_duration(total_seconds)
    return "N/A" if total_seconds.nil? || total_seconds.to_i < 0 # Lida com nil ou valores negativos
    puts("total sec = #{total_seconds}")
    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    format("%02dhs %02dmin %02ds", hours, minutes, seconds)
  end

  def format_total_time(total_time)
    return "Tempo não calculado" unless total_time

    # Se total_time é um objeto Time, extraímos horas, minutos e segundos
    if total_time.is_a?(Time)
      hours = total_time.hour
      minutes = total_time.min
      seconds = total_time.sec
    elsif total_time.is_a?(String)
      # Se for string no formato "HH:MM:SS"
      time_parts = total_time.split(':')
      hours = time_parts[0].to_i
      minutes = time_parts[1].to_i
      seconds = time_parts[2].to_i
    else
      return "Formato inválido"
    end

    "#{hours.to_s.rjust(2, '0')}h #{minutes.to_s.rjust(2, '0')}min #{seconds.to_s.rjust(2, '0')}s"
  end

  def calculate_duration(entry_time, exit_time)
    return "Tempo não calculado" unless entry_time && exit_time

    total_seconds = (exit_time - entry_time).to_i

    hours = total_seconds / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    "#{hours.to_s.rjust(2, '0')}h #{minutes.to_s.rjust(2, '0')}min #{seconds.to_s.rjust(2, '0')}s"
  end


end
