class VendorPolicy < ApplicationPolicy
  def index? = true

  def show? = true

  def create? = admin? || procurement_officer?

  def update? = admin? || procurement_officer?

  def destroy? = admin?

  def approve? = admin? || approver?

  def blacklist? = admin?

  def performance? = admin? || procurement_officer? || approver?

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