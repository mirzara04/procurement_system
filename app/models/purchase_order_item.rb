class PurchaseOrderItem < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product

  validates :product, presence: true
  validates :quantity, presence: true, 
    numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_total_price

  def total_amount
    quantity * unit_price
  end

  def product_name
    product&.name
  end

  private

  def set_total_price
    self.total_price = quantity.to_f * unit_price.to_f
  end
end