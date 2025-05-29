module ApplicationHelper

  def format_duration(duration_in_seconds)
    return "-" if duration_in_seconds.nil?

    total_seconds = duration_in_seconds.to_i

    # Segurança: se por algum motivo a duração for negativa (entry_time no futuro)
    return "0min" if total_seconds < 0

    hours = total_seconds / 3600         # Divisão inteira para obter horas
    minutes = (total_seconds % 3600) / 60 # Resto da divisão por 3600, depois dividido por 60 para obter minutos

    if hours > 0
      "#{hours}h #{minutes}min"
    else
      "#{minutes}min"
    end
  end

  # Check if the current controller and action match the provided ones
  def active_link?(controller, action = nil)
    if action.nil?
      controller_name == controller.to_s ? 'active' : ''
    else
      (controller_name == controller.to_s && action_name == action.to_s) ? 'active' : ''
    end
  end

  def spot_status_badge(status)
    case status
    when 'free'
      content_tag(:span, t("enums.parking_spot.status.free"), class: 'badge bg-success')
    when 'occupied'
      content_tag(:span, t("enums.parking_spot.status.occupied"), class: 'badge bg-danger')
    when 'blocked'
      content_tag(:span, t("enums.parking_spot.status.blocked"), class: 'badge bg-secondary')
    else
      content_tag(:span, status, class: 'badge bg-light text-dark')
    end
  end

  def spot_type_badge(type)
    case type
    when 'car'
      content_tag(:span, t("enums.parking_spot.spot_type.car"), class: 'badge bg-primary')
    when 'motorcycle'
      content_tag(:span, t("enums.parking_spot.spot_type.motorcycle"), class: 'badge bg-success')
    else
      content_tag(:span, type, class: 'badge bg-light text-dark')
    end
  end

  def spot_status_color(status)
  case status
  when 'free'
    'bg-success'
  when 'occupied'
    'bg-danger'
  when 'blocked'
    'bg-secondary'
  else
    'bg-light'
  end
end

end
