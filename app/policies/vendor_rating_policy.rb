class VendorRatingPolicy < ApplicationPolicy
  def index?   = true
  def create?  = user.present?
  def destroy? = admin? || record.user_id == user.id

  class Scope < Scope
    def resolve = scope.all
  end
end
