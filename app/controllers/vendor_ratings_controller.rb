class VendorRatingsController < ApplicationController
  before_action :set_vendor, only: [:index, :new, :create]
  before_action :set_rating, only: [:destroy]

  def index
    @ratings = @vendor.vendor_ratings.includes(:user, :purchase_order).order(created_at: :desc)
    authorize @ratings, :index?
  end

  def create
    @purchase_order = PurchaseOrder.find(params[:vendor_rating][:purchase_order_id])
    @rating = @vendor.vendor_ratings.build(rating_params)
    @rating.user = current_user
    @rating.purchase_order = @purchase_order
    authorize @rating

    if @rating.save
      redirect_to @purchase_order, notice: 'Rating submitted successfully.'
    else
      redirect_to @purchase_order, alert: "Failed to submit rating: #{@rating.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    authorize @rating
    vendor = @rating.vendor
    @rating.destroy
    redirect_to vendor, notice: 'Rating removed.'
  end

  private

  def set_vendor
    @vendor = Vendor.find(params[:vendor_id])
  end

  def set_rating
    @rating = VendorRating.find(params[:id])
  end

  def rating_params
    params.require(:vendor_rating).permit(:rating, :category, :comment, :purchase_order_id)
  end
end
