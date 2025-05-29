class ParkingLotPolicy < ApplicationPolicy
  def index?
    user.admin?  || user.manager?
  end

  def show?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.manager?
        scope.all
      else
        scope.none
      end
    end
  end
end
