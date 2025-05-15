class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, except: [:index, :new, :create]
  before_action :authorize_purchase_order, except: [:index, :new, :create]

  def index
    @q = PurchaseOrder.ransack(params[:q])
    @q.sorts = 'created_at desc' if @q.sorts.empty?
    @purchase_orders = @q.result.includes(:vendor, :created_by)
                        .page(params[:page]).per(20)
    authorize @purchase_orders
  end

  def show
    @recent_ratings = @purchase_order.vendor.vendor_ratings.order(created_at: :desc).limit(5)
  end

  def new
    @purchase_order = PurchaseOrder.new
    @purchase_order.purchase_order_items.build
    authorize @purchase_order
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.created_by = current_user
    @purchase_order.status = 'draft'
    authorize @purchase_order

    if @purchase_order.save
      redirect_to @purchase_order, notice: 'Purchase order was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @purchase_order.update(purchase_order_params)
      redirect_to @purchase_order, notice: 'Purchase order was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @purchase_order.can_be_deleted?
      @purchase_order.destroy
      redirect_to purchase_orders_url, notice: 'Purchase order was successfully deleted.'
    else
      redirect_to @purchase_order, alert: 'This purchase order cannot be deleted.'
    end
  end

  def submit_for_approval
    if @purchase_order.submit_for_approval
      redirect_to @purchase_order, notice: 'Purchase order has been submitted for approval.'
    else
      redirect_to @purchase_order, alert: 'Unable to submit purchase order for approval.'
    end
  end

  def approve
    if @purchase_order.approve(current_user)
      redirect_to @purchase_order, notice: 'Purchase order has been approved.'
    else
      redirect_to @purchase_order, alert: 'Unable to approve purchase order.'
    end
  end

  def reject
    if @purchase_order.reject(current_user, params[:rejection_reason])
      redirect_to @purchase_order, notice: 'Purchase order has been rejected.'
    else
      redirect_to @purchase_order, alert: 'Unable to reject purchase order.'
    end
  end

  def cancel
    if @purchase_order.cancel(current_user)
      redirect_to @purchase_order, notice: 'Purchase order has been cancelled.'
    else
      redirect_to @purchase_order, alert: 'Unable to cancel purchase order.'
    end
  end

  def mark_as_delivered
    if @purchase_order.mark_as_delivered(params[:actual_delivery_date])
      redirect_to @purchase_order, notice: 'Purchase order has been marked as delivered.'
    else
      redirect_to @purchase_order, alert: 'Unable to mark purchase order as delivered.'
    end
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def authorize_purchase_order
    authorize @purchase_order
  end

  def purchase_order_params
    params.require(:purchase_order).permit(
      :vendor_id, :expected_delivery_date, :shipping_address,
      :payment_terms, :currency, :notes, :status,
      purchase_order_items_attributes: [
        :id, :product_name, :description, :quantity, :unit_price, :_destroy
      ]
    )
  end
end 