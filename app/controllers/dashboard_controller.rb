class DashboardController < ApplicationController
  def index
    begin
      @pending_orders = PurchaseOrder.pending_approval.limit(5)
      @recent_orders = PurchaseOrder.order(created_at: :desc).limit(5)
      @vendor_count = Vendor.active_vendors.count
      @total_spend = PurchaseOrder.approved.sum(:total_amount)
      
      # Monthly spending chart data
      @monthly_spending = if PurchaseOrder.approved.any?
        PurchaseOrder.approved
          .group_by_month(:created_at, last: 12)
          .sum(:total_amount)
      else
        {}
      end

      # Top vendors by spend
      @top_vendors = Vendor.joins(:purchase_orders)
        .where(purchase_orders: { status: :approved })
        .group('vendors.id')
        .select('vendors.*, SUM(purchase_orders.total_amount) as total_spend')
        .order('total_spend DESC')
        .limit(5)
    rescue => e
      # Handle any errors gracefully
      logger.error "Dashboard error: #{e.message}"
      @pending_orders = []
      @recent_orders = []
      @vendor_count = 0
      @total_spend = 0
      @monthly_spending = {}
      @top_vendors = []
    end
  end

  def analytics
    # Date range for analytics
    @start_date = params[:start_date]&.to_date || 6.months.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current

    # Procurement trends
    @procurement_trends = PurchaseOrder
      .where(created_at: @start_date..@end_date)
      .group_by_month(:created_at)
      .sum(:total_amount)

    # Vendor performance
    @vendor_performance = VendorRating
      .where(created_at: @start_date..@end_date)
      .group(:vendor_id)
      .average(:rating)

    # Delivery performance
    @delivery_performance = PurchaseOrder
      .where(created_at: @start_date..@end_date)
      .where.not(actual_delivery_date: nil)
      .select("
        CASE 
          WHEN actual_delivery_date <= expected_delivery_date THEN 'on_time'
          ELSE 'delayed'
        END as delivery_status,
        COUNT(*) as count
      ")
      .group('delivery_status')

    # Category-wise spending
    @category_spending = PurchaseOrderItem
      .joins(:product)
      .where(created_at: @start_date..@end_date)
      .group('products.category')
      .sum(:total_price)
  end
end 