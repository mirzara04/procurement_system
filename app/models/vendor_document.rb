class VendorDocument < ApplicationRecord
  belongs_to :vendor
  belongs_to :uploaded_by, class_name: 'User'
  has_one_attached :file

  validates :document_type, presence: true
  validates :document_number, presence: true, uniqueness: { scope: :vendor_id }
  validates :status, presence: true
  validates :file, attached: true, content_type: [:pdf, :doc, :docx, :jpg, :jpeg, :png]
  validate :expiry_date_is_valid

  enum document_type: {
    registration: 'registration',
    tax: 'tax',
    certification: 'certification',
    contract: 'contract',
    insurance: 'insurance',
    other: 'other'
  }

  enum status: {
    active: 'active',
    expired: 'expired',
    pending: 'pending'
  }

  scope :active, -> { where(status: :active) }
  scope :expired, -> { where(status: :expired) }
  scope :expiring_soon, -> { where('expiry_date <= ?', 30.days.from_now) }

  before_save :update_status_based_on_expiry

  private

  def expiry_date_is_valid
    return unless expiry_date.present? && issue_date.present?
    if expiry_date < issue_date
      errors.add(:expiry_date, "must be after the issue date")
    end
  end

  def update_status_based_on_expiry
    return unless expiry_date.present?
    self.status = if expiry_date < Date.current
                    'expired'
                  else
                    'active'
                  end
  end
end 