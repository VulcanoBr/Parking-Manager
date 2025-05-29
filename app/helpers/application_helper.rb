module ApplicationHelper

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
