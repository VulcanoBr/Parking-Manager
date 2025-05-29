class ParkingSpotPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def update?
    user.admin?
  end

  def edit?
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
