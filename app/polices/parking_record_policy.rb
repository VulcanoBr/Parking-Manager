class ParkingRecordPolicy < ApplicationPolicy
  def index?
    user.admin? || user.manager?
  end

  def show?
    user.admin? || user.manager?
  end

  def create?
    user.admin? || user.manager?
  end

  def edit?
    user.admin? || user.manager?
  end

  def update?
    user.admin? || user.manager?
  end

  def checkout?
    user.admin? || user.manager?
  end

  def payment?
    user.admin? || user.manager?
  end

  def mark_as_paid?
    user.admin? || user.manager?
  end

  def next_available_spot?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? # Só admins podem deletar
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
