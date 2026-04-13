class ReportPolicy < ApplicationPolicy
  def index?
    user.admin? || user.approver?
  end

  def vendor_performance?
    user.admin? || user.approver?
  end

  def procurement_analytics?
    user.admin? || user.approver?
  end

  def delivery_performance?
    user.admin? || user.approver?
  end

  def spending_analysis?
    user.admin? || user.approver?
  end
end 