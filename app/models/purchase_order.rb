# app/models/purchase_order.rb
class PurchaseOrder < ApplicationRecord
  include PaperTrail::Model
  include AASM

  # Constants
  PAYMENT_TERMS = %w[
    Net\ 30
    Net\ 45
    Net\ 60
    Due\ on\ Receipt
    Due\ End\ of\ Month
    Cash\ on\ Delivery
  ].freeze

  CURRENCIES = %w[USD EUR GBP JPY AUD CAD].freeze

  # Associations
  belongs_to :vendor
  belongs_to :created_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true
  has_many :purchase_order_items, dependent: :destroy
  has_many :vendor_ratings, dependent: :destroy

  accepts_nested_attributes_for :purchase_order_items,
                              reject_if: :all_blank,
                              allow_destroy: true

  # Validations
  validates :po_number, presence: true, uniqueness: true
  validates :vendor_id, :expected_delivery_date, :shipping_address, presence: true
  validates :payment_terms, inclusion: { in: PAYMENT_TERMS }, allow_nil: true
  validates :currency, inclusion: { in: CURRENCIES }
  validate :expected_delivery_date_cannot_be_in_past, on: :create
  validate :must_have_at_least_one_item
  validate :approved_by_must_be_present_when_approved

  # Callbacks
  before_validation :generate_po_number, on: :create
  before_save :calculate_total_amount

  # State Machine (AASM)
  aasm column: :status, whiny_transitions: true do
    state :draft, initial: true
    state :pending_approval
    state :approved
    state :in_progress
    state :delivered
    state :cancelled
    state :rejected

    event :submit do
      transitions from: :draft, to: :pending_approval, 
                after: :notify_approvers
    end

    event :approve do
      transitions from: :pending_approval, to: :approved, 
                after: :record_approval,
                guard: :has_approver?
    end

    event :reject do
      transitions from: :pending_approval, to: :rejected, 
                after: :record_rejection,
                guard: :has_rejection_reason?
    end

    event :cancel do
      transitions from: %i[approved in_progress], to: :cancelled, 
                guard: :can_be_cancelled?,
                after: :record_cancellation
    end

    event :mark_in_progress do
      transitions from: :approved, to: :in_progress,
                after: :record_in_progress
    end

    event :mark_delivered do
      transitions from: %i[approved in_progress], to: :delivered, 
                after: :record_delivery,
                guard: :has_actual_delivery_date?
    end
  end

  # Scopes
  scope :pending_approval, -> { where(status: :pending_approval) }
  scope :approved, -> { where(status: :approved) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :delivered, -> { where(status: :delivered) }
  scope :this_month, -> { where(created_at: Time.current.all_month) }
  scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }
  scope :recent, -> { order(created_at: :desc).limit(5) }
  scope :with_items, -> { includes(:purchase_order_items) }
  scope :search_by_term, ->(term) {
    where('po_number ILIKE :term', term: "%#{term}%")
  }

  # Class Methods
  def self.total_spend
    approved.sum(:total_amount)
  end

  def self.monthly_spend
    approved.group_by_month(:created_at, last: 12).sum(:total_amount)
  end

  # Instance Methods
  def can_be_deleted?
    draft?
  end

  def can_be_cancelled?
    !cancelled? && !delivered? && !draft?
  end

  def overdue?
    expected_delivery_date < Date.current && !delivered?
  end

  def days_until_delivery
    (expected_delivery_date - Date.current).to_i if expected_delivery_date
  end

  # State Transition Methods
  def submit_for_approval!
    return false unless draft?

    transaction do
      submit!
      true
    rescue StandardError => e
      errors.add(:base, "Failed to submit for approval: #{e.message}")
      false
    end
  end

  def approve!(approver)
    return false unless pending_approval?

    transaction do
      self.approved_by = approver
      self.approved_at = Time.current
      approve!
      true
    rescue StandardError => e
      errors.add(:base, "Failed to approve: #{e.message}")
      false
    end
  end

  def reject!(user, reason)
    return false unless pending_approval?

    transaction do
      self.rejection_reason = reason
      self.rejected_by = user
      self.rejected_at = Time.current
      reject!
      true
    rescue StandardError => e
      errors.add(:base, "Failed to reject: #{e.message}")
      false
    end
  end

  def cancel!(user)
    return false unless can_be_cancelled?

    transaction do
      self.cancelled_by = user
      self.cancelled_at = Time.current
      cancel!
      true
    rescue StandardError => e
      errors.add(:base, "Failed to cancel: #{e.message}")
      false
    end
  end

  def mark_delivered!(delivery_date)
    return false unless approved? || in_progress?

    transaction do
      self.actual_delivery_date = delivery_date
      mark_delivered!
      true
    rescue StandardError => e
      errors.add(:base, "Failed to mark as delivered: #{e.message}")
      false
    end
  end

  private

  def generate_po_number
    return if po_number.present?

    last_number = self.class.maximum("CAST(SUBSTRING(po_number FROM 3) AS integer)") || 0
    self.po_number = format('PO%07d', last_number + 1)
  end

  def calculate_total_amount
    self.total_amount = purchase_order_items.reject(&:marked_for_destruction?).sum(&:total_price)
  rescue StandardError => e
    errors.add(:base, "Failed to calculate total: #{e.message}")
    throw :abort
  end

  def expected_delivery_date_cannot_be_in_past
    return unless expected_delivery_date.present? && expected_delivery_date < Date.current
    errors.add(:expected_delivery_date, "can't be in the past")
  end

  def must_have_at_least_one_item
    return unless purchase_order_items.reject(&:marked_for_destruction?).empty?
    errors.add(:base, "Must have at least one item")
  end

  def approved_by_must_be_present_when_approved
    return unless approved? && approved_by.nil?
    errors.add(:approved_by, "must be present when purchase order is approved")
  end

  # State transition guards
  def has_approver?
    approved_by.present?
  end

  def has_rejection_reason?
    rejection_reason.present?
  end

  def has_actual_delivery_date?
    actual_delivery_date.present?
  end

  # State transition callbacks
  def notify_approvers
    PurchaseOrderMailer.approval_request(self).deliver_later
  end

  def record_approval
    # Additional logic when approved
  end

  def record_rejection
    # Additional logic when rejected
  end

  def record_cancellation
    # Additional logic when cancelled
  end

  def record_delivery
    # Additional logic when delivered
  end

  def record_in_progress
    # Additional logic when marked in progress
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      created_at delivery_date id order_date po_number status
      total_amount updated_at vendor_id expected_delivery_date
      actual_delivery_date
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vendor created_by approved_by purchase_order_items vendor_ratings]
  end
end