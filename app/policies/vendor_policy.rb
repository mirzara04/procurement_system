class VendorPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin? || procurement_officer?
  end

  def update?
    admin? || procurement_officer?
  end

  def destroy?
    admin?
  end

  def approve?
    admin? || approver?
  end

  def blacklist?
    admin?
  end

  def performance?
    admin? || procurement_officer? || approver?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where.not(status: :blacklisted)
      end
    end
  end
end 