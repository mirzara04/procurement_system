class PurchaseOrderItem < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product

  validates :product_name, presence: true
  validates :quantity, presence: true, 
    numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_total_amount

  def total_amount
    quantity * unit_price
  end

  private

  def calculate_total_amount
    self.total_amount = total_amount
  end
end
