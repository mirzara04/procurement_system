class Vendor < ApplicationRecord
  # Constants
  PHONE_REGEX = /\A\+?[\d\s-]{8,}\z/
  
  # Relationships
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :products
  has_many :vendor_ratings
  has_many :vendor_documents

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :phone,
            presence: true,
            format: { with: PHONE_REGEX, message: "must be a valid phone number" }
  validates :tax_number, uniqueness: true, allow_blank: true
  validates :status, presence: true

  # Enums with prefix option for better method names
  enum :status, {
    active: 0,
    inactive: 1,
    blacklisted: 2,
    pending_approval: 3
  }, _prefix: true

  # Scopes
  scope :active_vendors, -> { where(status: :active) }
  scope :pending_approval, -> { where(status: :pending_approval) }
  scope :search_by_term, ->(term) {
    where('name ILIKE :term OR email ILIKE :term OR tax_number ILIKE :term',
          term: "%#{term}%")
  }
  scope :with_recent_orders, -> {
    joins(:purchase_orders)
      .where(purchase_orders: { created_at: 3.months.ago.. })
      .distinct
  }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_rating, -> {
    joins(:vendor_ratings)
      .group(:id)
      .average(:rating)
  }
  scope :ordered_by_name, -> { order(:name) }
  scope :with_purchase_orders, -> { includes(:purchase_orders) }

  # Callbacks
  before_validation :normalize_email
  before_validation :normalize_phone

  # Class Methods
  def self.top_performers(limit = 5)
    joins(:vendor_ratings)
      .group(:id)
      .having('AVG(vendor_ratings.rating) >= ?', 4.0)
      .limit(limit)
  end

  # Instance Methods
  def average_rating
    vendor_ratings.average(:rating)&.round(2) || 0
  end

  def total_purchase_orders_amount
    purchase_orders.sum(:total_amount)
  end

  def recent_purchase_orders(limit = 5)
    purchase_orders.order(created_at: :desc).limit(limit)
  end

  def total_spend
    purchase_orders.delivered.sum(:total_amount)
  end

  def performance_status
    case average_rating
    when 4.5.. then :excellent
    when 3.5...4.5 then :good
    when 2.5...3.5 then :average
    else :poor
    end
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_phone
    self.phone = phone.gsub(/[^\d+\s-]/, '') if phone.present?
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[name email phone tax_number status created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[purchase_orders products vendor_ratings vendor_documents]
  end
end
