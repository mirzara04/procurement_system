class ProductPolicy < ApplicationPolicy
  def index? = true

  def show? = true

  def create? = admin? || procurement_officer?

  def update? = admin? || procurement_officer?

  def destroy? = admin?

  def low_stock? = admin? || procurement_officer?

  def discontinued? = admin? || procurement_officer?

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where.not(status: :discontinued)
      end
    end
  end
end 