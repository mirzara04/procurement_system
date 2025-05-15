class PurchaseOrderMailer < ApplicationMailer
  def approval_request(purchase_order)
    @purchase_order = purchase_order
    @user = purchase_order.created_by
    @url = purchase_order_url(@purchase_order)

    mail(
      to: User.approvers.pluck(:email),
      subject: "Purchase Order ##{@purchase_order.po_number} Requires Approval"
    )
  end

  def approved_notification(purchase_order)
    @purchase_order = purchase_order
    @user = purchase_order.created_by
    @approver = purchase_order.approved_by
    @url = purchase_order_url(@purchase_order)

    mail(
      to: @user.email,
      subject: "Purchase Order ##{@purchase_order.po_number} Has Been Approved"
    )
  end

  def rejected_notification(purchase_order)
    @purchase_order = purchase_order
    @user = purchase_order.created_by
    @rejection_reason = purchase_order.rejection_reason
    @url = purchase_order_url(@purchase_order)

    mail(
      to: @user.email,
      subject: "Purchase Order ##{@purchase_order.po_number} Has Been Rejected"
    )
  end

  def cancelled_notification(purchase_order)
    @purchase_order = purchase_order
    @user = purchase_order.created_by
    @cancelled_by = purchase_order.cancelled_by
    @url = purchase_order_url(@purchase_order)

    recipients = [@user.email]
    recipients << @purchase_order.vendor.email if @purchase_order.approved?

    mail(
      to: recipients,
      subject: "Purchase Order ##{@purchase_order.po_number} Has Been Cancelled"
    )
  end

  def delivery_notification(purchase_order)
    @purchase_order = purchase_order
    @user = purchase_order.created_by
    @url = purchase_order_url(@purchase_order)

    mail(
      to: @user.email,
      subject: "Purchase Order ##{@purchase_order.po_number} Has Been Delivered"
    )
  end
end 