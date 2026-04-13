class Product < ApplicationRecord
  # Relationships
  belongs_to :vendor, optional: true
  has_many :purchase_order_items, dependent: :restrict_with_error
  has_many :purchase_orders, through: :purchase_order_items

  # Validations
  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :current_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_point, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_order_quantity, numericality: { greater_than: 0 }, allow_nil: true

  # Enums
  enum :status, {
    active: 0,
    discontinued: 1,
    out_of_stock: 2
  }, default: :active

  enum :category, {
    electronics: 0,
    furniture: 1,
    office_supplies: 2,
    it_equipment: 3,
    software: 4,
    services: 5,
    other: 6
  }

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :discontinued, -> { where(status: :discontinued) }
  scope :low_stock, -> { where('current_stock <= reorder_point') }
  scope :by_category, ->(category) { where(category: category) }
  scope :search_by_term, ->(term) {
    where('name ILIKE :term OR sku ILIKE :term OR description ILIKE :term',
          term: "%#{term}%")
  }

  # Instance methods
  def low_stock? = current_stock <= (reorder_point || 0)

  def total_ordered_quantity = purchase_order_items.sum(:quantity)

  def total_ordered_amount = purchase_order_items.sum('quantity * unit_price')

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[name sku category status unit_price current_stock created_at updated_at id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vendor purchase_order_items purchase_orders]
  end
end
