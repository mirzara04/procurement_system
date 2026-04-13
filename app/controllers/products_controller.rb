class ProductsController < ApplicationController
  before_action :set_product, except: %i[index new create]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(Product).ransack(params[:q])
    @products = @q.result(distinct: true)
                 .includes(:vendor)
                 .page(params[:page])
  end

  def show
    authorize @product
  end

  def new
    @product = Product.new
    authorize @product
  end

  def create
    @product = Product.new(product_params)
    authorize @product

    if @product.save
      redirect_to @product, notice: t('.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product
    if @product.update(product_params)
      redirect_to @product, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    if @product.purchase_order_items.exists?
      redirect_to @product, alert: t('.has_orders'), status: :unprocessable_entity
    else
      @product.destroy
      redirect_to products_url, notice: t('.success')
    end
  end

  def low_stock
    authorize Product
    @products = policy_scope(Product)
                .where('current_stock <= reorder_point')
                .includes(:vendor)
                .page(params[:page])
  end

  def discontinued
    authorize Product
    @products = policy_scope(Product)
                .where(status: :discontinued)
                .includes(:vendor)
                .page(params[:page])
  end

  private

  def set_product = @product = Product.find(params[:id])

  def product_params
    params.require(:product).permit(
      :name, :description, :sku, :unit_price,
      :vendor_id, :category, :status,
      :current_stock, :reorder_point, :minimum_order_quantity
    )
  end
end 