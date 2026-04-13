class VendorDocumentPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def create?  = admin? || procurement_officer?
  def new?     = create?
  def destroy? = admin?

  class Scope < Scope
    def resolve = scope.all
  end
end
