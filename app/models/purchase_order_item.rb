class PurchaseOrderItem < ApplicationRecord
  # Associations
  belongs_to :purchase_order
  belongs_to :product, optional: true

  # Validations
  validates :product_name, presence: true
  validates :quantity,
            presence: true,
            numericality: { greater_than: 0, only_integer: true }
  validates :unit_price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :total_price,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # Callbacks
  before_save :calculate_total_price
  after_save :update_purchase_order_total
  after_destroy :update_purchase_order_total

  # Scopes
  scope :ordered_by_product_name, -> { order(:product_name) }
  scope :with_product, -> { includes(:product) }
  scope :high_value, ->(threshold = 1000) { where('total_price >= ?', threshold) }

  # Instance Methods
  def total_price
    return nil unless quantity? && unit_price?
    
    (quantity * unit_price).round(2)
  end

  def high_quantity?
    quantity >= 100
  end

  def discount_eligible?
    high_quantity? || total_price >= 1000
  end

  private

  def calculate_total_price
    self.total_price = total_price
  end

  def update_purchase_order_total
    purchase_order.calculate_total_amount
    purchase_order.save
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[product_name quantity unit_price total_price created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[purchase_order product]
  end
end
