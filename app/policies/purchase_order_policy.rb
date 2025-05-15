class PurchaseOrderPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    return false unless user.present?
    return true if user.admin?
    return true if user.approver? && record.pending_approval?
    return true if record.created_by_id == user.id && record.draft?
    false
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user.present?
    return true if user.admin?
    record.created_by_id == user.id && record.draft?
  end

  def submit_for_approval?
    return false unless user.present?
    record.created_by_id == user.id && record.draft?
  end

  def approve?
    return false unless user.present?
    (user.admin? || user.approver?) && record.pending_approval?
  end

  def reject?
    approve?
  end

  def cancel?
    return false unless user.present?
    return true if user.admin?
    return true if user.approver?
    record.created_by_id == user.id && record.can_be_cancelled?
  end

  def mark_as_delivered?
    return false unless user.present?
    return true if user.admin?
    return true if user.approver?
    record.created_by_id == user.id && record.approved?
  end

  def rate?
    return false unless user.present?
    return false unless record.delivered?
    record.created_by_id == user.id && !record.vendor_ratings.exists?(user_id: user.id)
  end

  def print?
    show?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.approver?
        scope.all
      else
        scope.where(created_by_id: user.id)
      end
    end
  end
end 