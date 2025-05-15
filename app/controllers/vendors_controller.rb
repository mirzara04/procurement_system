class VendorsController < ApplicationController
  before_action :set_vendor, except: [:index, :new, :create]
  after_action :verify_authorized, except: [:index]

  def index
    @q = Vendor.ransack(params[:q])
    @vendors = @q.result(distinct: true)
      .includes(:vendor_ratings)
      .page(params[:page])
  end

  def show
    authorize @vendor
    @recent_orders = @vendor.purchase_orders.order(created_at: :desc).limit(5)
    @ratings = @vendor.vendor_ratings.includes(:user).recent
    @documents = @vendor.vendor_documents.includes(:uploaded_by)
  end

  def new
    @vendor = Vendor.new
    authorize @vendor
  end

  def create
    @vendor = Vendor.new(vendor_params)
    authorize @vendor

    if @vendor.save
      redirect_to @vendor, notice: 'Vendor was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @vendor
  end

  def update
    authorize @vendor
    if @vendor.update(vendor_params)
      redirect_to @vendor, notice: 'Vendor was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @vendor
    if @vendor.purchase_orders.exists?
      redirect_to @vendor, alert: 'Cannot delete vendor with associated purchase orders.'
    else
      @vendor.destroy
      redirect_to vendors_url, notice: 'Vendor was successfully deleted.'
    end
  end

  def approve
    authorize @vendor
    if @vendor.update(status: :active)
      redirect_to @vendor, notice: 'Vendor was successfully approved.'
    else
      redirect_to @vendor, alert: 'Failed to approve vendor.'
    end
  end

  def blacklist
    authorize @vendor
    if @vendor.update(status: :blacklisted)
      redirect_to @vendor, notice: 'Vendor was successfully blacklisted.'
    else
      redirect_to @vendor, alert: 'Failed to blacklist vendor.'
    end
  end

  def performance
    authorize @vendor
    @ratings_by_category = @vendor.vendor_ratings
      .group(:category)
      .average(:rating)
    
    @delivery_performance = @vendor.purchase_orders
      .where.not(actual_delivery_date: nil)
      .select("
        CASE 
          WHEN actual_delivery_date <= expected_delivery_date THEN 'on_time'
          ELSE 'delayed'
        END as delivery_status,
        COUNT(*) as count
      ")
      .group('delivery_status')

    @monthly_orders = @vendor.purchase_orders
      .group_by_month(:created_at, last: 12)
      .count
  end

  private

  def set_vendor
    @vendor = Vendor.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(
      :name, :email, :phone, :address, :tax_number,
      :contact_person, :website, :registration_number,
      :notes
    )
  end
end 