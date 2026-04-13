class ReportsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize :report, :index?
    @total_vendors = Vendor.count
    @active_vendors = Vendor.active.count
    @total_products = Product.count
    @low_stock_products = Product.low_stock.count
    @total_purchase_orders = PurchaseOrder.count
    @pending_approval_pos = PurchaseOrder.pending_approval.count
    
    @monthly_po_amounts = PurchaseOrder.approved
                                     .group_by_month(:created_at, last: 12)
                                     .sum(:total_amount)
    
    @top_vendors = Vendor.joins(:purchase_orders)
                        .where(purchase_orders: { status: :approved })
                        .group('vendors.id')
                        .select('vendors.*, SUM(purchase_orders.total_amount) as total_spend')
                        .order('total_spend DESC')
                        .limit(5)
  end

  def vendor_performance
    authorize :report, :vendor_performance?

    if params[:vendor_id].blank?
      @vendors = Vendor.active.order(:name)
      render :select_vendor and return
    end

    @vendor = Vendor.find_by(id: params[:vendor_id])
    unless @vendor
      redirect_to reports_path, alert: 'Vendor not found.' and return
    end
    
    @ratings_by_category = @vendor.vendor_ratings
                                .group(:category)
                                .average(:rating)
    
    @delivery_performance = @vendor.purchase_orders
                                 .where.not(delivery_date: nil)
                                 .group("CASE 
                                   WHEN delivery_date <= expected_delivery_date THEN 'on_time'
                                   ELSE 'delayed'
                                 END")
                                 .count
    
    @monthly_orders = @vendor.purchase_orders
                            .group_by_month(:created_at, last: 12)
                            .count
                            
    @monthly_spend = @vendor.purchase_orders
                           .where(status: :approved)
                           .group_by_month(:created_at, last: 12)
                           .sum(:total_amount)
  end

  def procurement_analytics
    authorize :report, :procurement_analytics?
    
    # Category-wise spending
    @category_spend = PurchaseOrder.approved
                                 .joins(purchase_order_items: :product)
                                 .group('products.category')
                                 .sum('purchase_order_items.quantity * purchase_order_items.unit_price')

    # Monthly order trends
    @monthly_order_trends = PurchaseOrder.group_by_month(:created_at, last: 12)
                                       .group(:status)
                                       .count

    # Average processing time (days between creation and approval)
    @avg_processing_time = PurchaseOrder.approved
                                      .where.not(approved_at: nil)
                                      .average("EXTRACT(EPOCH FROM (approved_at - created_at)) / 86400")

    # Top ordered products
    @top_products = Product.joins(:purchase_order_items)
                          .group('products.id')
                          .select('products.*, SUM(purchase_order_items.quantity) as total_ordered')
                          .order('total_ordered DESC')
                          .limit(10)

    # Order value distribution
    @order_value_distribution = PurchaseOrder.approved
                                           .group("CASE 
                                             WHEN total_amount < 1000 THEN 'Under $1,000'
                                             WHEN total_amount < 5000 THEN '$1,000 - $4,999'
                                             WHEN total_amount < 10000 THEN '$5,000 - $9,999'
                                             ELSE '$10,000+'
                                           END")
                                           .count
  end

  def delivery_performance
    authorize :report, :delivery_performance?
    
    # Overall delivery performance
    @overall_delivery = PurchaseOrder.where.not(delivery_date: nil)
                                   .group("CASE 
                                     WHEN delivery_date <= expected_delivery_date THEN 'On Time'
                                     WHEN delivery_date <= expected_delivery_date + INTERVAL '7 days' THEN 'Delayed (1-7 days)'
                                     ELSE 'Significantly Delayed (>7 days)'
                                   END")
                                   .count

    # Monthly delivery performance
    @monthly_delivery = PurchaseOrder.where.not(delivery_date: nil)
                                   .group_by_month(:delivery_date, last: 12)
                                   .group("CASE 
                                     WHEN delivery_date <= expected_delivery_date THEN 'on_time'
                                     ELSE 'delayed'
                                   END")
                                   .count

    # Average delay by vendor (top 10 worst performers)
    @vendor_delays = Vendor.joins(:purchase_orders)
                          .where.not(purchase_orders: { delivery_date: nil })
                          .group('vendors.id')
                          .select('vendors.*, 
                                 AVG(EXTRACT(EPOCH FROM (delivery_date - expected_delivery_date)) / 86400) as avg_delay_days')
                          .having('AVG(EXTRACT(EPOCH FROM (delivery_date - expected_delivery_date)) / 86400) > 0')
                          .order('avg_delay_days DESC')
                          .limit(10)

    # Delivery performance by order value range
    @delivery_by_value = PurchaseOrder.where.not(delivery_date: nil)
  .group("CASE 
    WHEN total_amount < 5000 THEN 'Under $5,000'
    WHEN total_amount < 10000 THEN '$5,000 - $9,999'
    WHEN total_amount < 50000 THEN '$10,000 - $49,999'
    ELSE '$50,000+'
  END")
  .group("CASE 
    WHEN delivery_date <= expected_delivery_date THEN 'on_time'
    ELSE 'delayed'
  END")
  .count
  end

  def spending_analysis
    authorize :report, :spending_analysis?
    
    # Department-wise spending
    @department_spend = PurchaseOrder.approved
                                   .joins(:created_by)
                                   .group('COALESCE(users.department, \'Unassigned\')')
                                   .sum(:total_amount)

    # Monthly spending trends
    @monthly_spending = PurchaseOrder.approved
                                   .group_by_month(:created_at, last: 12)
                                   .sum(:total_amount)

    # Budget utilization (assuming monthly budget)
    @budget_utilization = PurchaseOrder.approved
                                     .where('created_at >= ?', Time.current.beginning_of_month)
                                     .sum(:total_amount)

    # Top spending users
    @top_spenders = User.joins(:created_purchase_orders)
                       .where(purchase_orders: { status: :approved })
                       .group('users.id')
                       .select('users.*, SUM(purchase_orders.total_amount) as total_spend')
                       .order('total_spend DESC')
                       .limit(10)

    # Spending by expense category
    @expense_categories = PurchaseOrder.approved
                                     .joins(:purchase_order_items)
                                     .group('purchase_order_items.expense_category')
                                     .sum('purchase_order_items.quantity * purchase_order_items.unit_price')

    # Year-over-year comparison
    @yearly_comparison = PurchaseOrder.approved
                                    .group_by_year(:created_at, last: 2)
                                    .sum(:total_amount)
  end
end