class VendorsController < ApplicationController
  before_action :set_vendor, except: %i[index new create]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(Vendor).ransack(params[:q])
    @vendors = @q.result(distinct: true)
                 .includes(:vendor_ratings, :purchase_orders)
                 .page(params[:page])
  end

  def show
    authorize @vendor
    @recent_orders = @vendor.purchase_orders
                           .includes(:created_by)
                           .order(created_at: :desc)
                           .limit(5)
    @ratings = @vendor.vendor_ratings
                     .includes(:user)
                     .recent
    @documents = @vendor.vendor_documents
                       .includes(:uploaded_by)
  end

  def new
    @vendor = Vendor.new
    authorize @vendor
  end

  def create
    @vendor = Vendor.new(vendor_params)
    authorize @vendor

    if @vendor.save
      redirect_to @vendor, notice: t('.success')
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
      redirect_to @vendor, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @vendor
    if @vendor.purchase_orders.exists?
      redirect_to @vendor, alert: t('.has_orders'), status: :unprocessable_entity
    else
      @vendor.destroy
      redirect_to vendors_url, notice: t('.success')
    end
  end

  def approve
    authorize @vendor
    if @vendor.update(status: :active)
      redirect_to @vendor, notice: t('.success')
    else
      redirect_to @vendor, alert: t('.failure'), status: :unprocessable_entity
    end
  end

  def blacklist
    authorize @vendor
    if @vendor.update(status: :blacklisted)
      redirect_to @vendor, notice: t('.success')
    else
      redirect_to @vendor, alert: t('.failure'), status: :unprocessable_entity
    end
  end

  def performance
    authorize @vendor
    @ratings_by_category = @vendor.vendor_ratings
                                .group(:category)
                                .average(:rating)
    
    @delivery_performance = @vendor.purchase_orders
                                 .where.not(delivery_date: nil)
                                 .select(delivery_performance_query)
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
      :name, :email, :phone, :address, :tax_id,
      :contact_person, :website, :registration_number,
      :notes, :status
    )
  end

  def delivery_performance_query
    <<~SQL
      CASE 
        WHEN delivery_date <= expected_delivery_date THEN 'on_time'
        ELSE 'delayed'
      END as delivery_status,
      COUNT(*) as count
    SQL
  end
end 