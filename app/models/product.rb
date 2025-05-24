class Product < ApplicationRecord
  # Constants
  MINIMUM_STOCK_THRESHOLD = 10
  
  # Associations
  belongs_to :vendor, optional: true
  has_many :purchase_order_items, dependent: :nullify
  has_many :purchase_orders, through: :purchase_order_items

  # Validations
  validates :name, presence: true
  validates :sku,
            presence: true,
            uniqueness: true,
            format: { with: /\A[A-Z0-9\-_]+\z/, message: "only allows uppercase letters, numbers, hyphens and underscores" }
  validates :unit_price,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :quantity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category, presence: true

  # Callbacks
  before_save :normalize_sku
  after_save :check_stock_level

  # Scopes
  scope :low_stock, -> { where('quantity <= ?', MINIMUM_STOCK_THRESHOLD) }
  scope :in_stock, -> { where('quantity > 0') }
  scope :out_of_stock, -> { where(quantity: 0) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :active, -> { where(active: true) }
  scope :ordered_by_name, -> { order(:name) }
  scope :with_vendor, -> { includes(:vendor) }
  scope :popular, -> {
    joins(:purchase_order_items)
      .group(:id)
      .order('COUNT(purchase_order_items.id) DESC')
  }

  # Class Methods
  def self.categories_with_counts
    group(:category).count
  end

  def self.total_inventory_value
    sum('quantity * unit_price')
  end

  # Instance Methods
  def low_stock?
    quantity <= MINIMUM_STOCK_THRESHOLD
  end

  def in_stock?
    quantity.positive?
  end

  def total_value
    quantity * unit_price
  end

  def sales_count
    purchase_order_items.sum(:quantity)
  end

  def total_sales_value
    purchase_order_items.sum('quantity * unit_price')
  end

  private

  def normalize_sku
    self.sku = sku.upcase.strip if sku.present?
  end

  def check_stock_level
    return unless saved_change_to_quantity? && low_stock?
    # Implement stock level notification logic here
    # StockLevelNotifier.notify_low_stock(self)
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[name sku category unit_price quantity created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vendor purchase_order_items purchase_orders]
  end
end
