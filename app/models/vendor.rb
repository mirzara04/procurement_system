class Vendor < ApplicationRecord
  # Relationships
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :products
  has_many :vendor_ratings
  has_many :vendor_documents

  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :tax_number, uniqueness: true, allow_blank: true
  validates :status, presence: true

  # Enums
  enum status: {
    active: 0,
    inactive: 1,
    blacklisted: 2,
    pending_approval: 3
  }

  # Scopes
  scope :active_vendors, -> { where(status: :active) }
  scope :pending_approval, -> { where(status: :pending_approval) }

  # Search scope
  scope :search_by_term, ->(term) {
    where('name ILIKE :term OR email ILIKE :term OR tax_number ILIKE :term',
          term: "%#{term}%")
  }

  # Instance methods
  def average_rating
    vendor_ratings.average(:rating) || 0
  end

  def total_purchase_orders_amount
    purchase_orders.sum(:total_amount)
  end

  def recent_purchase_orders
    purchase_orders.order(created_at: :desc).limit(5)
  end
end
