class ReportPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def occupancy?
    user.admin?
  end

  def revenue?
    user.admin?
  end

  def average_time?
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
