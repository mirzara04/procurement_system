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

  # Nested attributes configuration
  accepts_nested_attributes_for :purchase_order_items,
                               reject_if: :all_blank,
                               allow_destroy: true

  # Validations
  validates :po_number, presence: true, uniqueness: true
  validates :vendor_id, :expected_delivery_date, :shipping_address, presence: true
  validates :status, presence: true
  validates :payment_terms, inclusion: { in: PAYMENT_TERMS }, allow_nil: true
  validates :currency, inclusion: { in: CURRENCIES }
  validate :expected_delivery_date_cannot_be_in_past, on: :create
  validate :must_have_at_least_one_item

  # Enum for status
  enum :status, {
    draft: 'draft',
    pending_approval: 'pending_approval',
    approved: 'approved',
    in_progress: 'in_progress',
    delivered: 'delivered',
    cancelled: 'cancelled',
    rejected: 'rejected'
  }, default: :draft

  # State Machine (AASM)
  aasm column: :status do
    state :draft, initial: true
    state :pending_approval
    state :approved
    state :in_progress
    state :delivered
    state :cancelled
    state :rejected

    event :submit do
      transitions from: :draft, to: :pending_approval
    end

    event :approve do
      transitions from: :pending_approval, to: :approved, after: :record_approval
    end

    event :reject do
      transitions from: :pending_approval, to: :rejected, after: :record_rejection
    end

    event :cancel do
      transitions from: [:approved, :in_progress], to: :cancelled, 
                guard: :can_be_cancelled?,
                after: :record_cancellation
    end

    event :mark_in_progress do
      transitions from: :approved, to: :in_progress
    end

    event :mark_delivered do
      transitions from: [:approved, :in_progress], to: :delivered, after: :record_delivery
    end
  end

  # Scopes
  scope :pending_approval, -> { where(status: 'pending_approval') }
  scope :approved, -> { where(status: 'approved') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :this_month, -> { where(created_at: Time.current.all_month) }
  scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }

  # Business Logic
  def can_be_deleted?
    draft?
  end

  def can_be_cancelled?
    !cancelled? && !delivered? && !draft?
  end

  # State Transition Methods (called by controller)
  def submit_for_approval
    return false unless draft?
    transaction do
      submit!
      PurchaseOrderMailer.approval_request(self).deliver_later
      true
    rescue StandardError => e
      errors.add(:base, "Failed to submit for approval: #{e.message}")
      false
    end
  end

  def approve(approver)
    return false unless pending_approval?
    transaction do
      self.approved_by = approver
      self.approved_at = Time.current
      approve!
      PurchaseOrderMailer.approved_notification(self).deliver_later
      true
    rescue StandardError => e
      errors.add(:base, "Failed to approve: #{e.message}")
      false
    end
  end

  def reject(approver, reason = nil)
    return false unless pending_approval?
    transaction do
      self.rejection_reason = reason if respond_to?(:rejection_reason=)
      reject!
      PurchaseOrderMailer.rejected_notification(self).deliver_later
      true
    rescue StandardError => e
      errors.add(:base, "Failed to reject: #{e.message}")
      false
    end
  end

  def cancel(user)
    return false unless can_be_cancelled?
    transaction do
      cancel!
      PurchaseOrderMailer.cancelled_notification(self).deliver_later
      true
    rescue StandardError => e
      errors.add(:base, "Failed to cancel: #{e.message}")
      false
    end
  end

  def mark_as_delivered(delivery_date = nil)
    return false unless approved? || in_progress?
    transaction do
      self.delivery_date = delivery_date.present? ? delivery_date.to_date : Date.current
      mark_delivered!
      PurchaseOrderMailer.delivery_notification(self).deliver_later
      true
    rescue StandardError => e
      errors.add(:base, "Failed to mark as delivered: #{e.message}")
      false
    end
  end

  before_validation :generate_po_number, on: :create

  private

  def generate_po_number
    self.po_number ||= "PO-#{SecureRandom.hex(6).upcase}"
  end

  def calculate_total_amount
    self.total_amount = purchase_order_items.sum(&:total_price)
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

  # State transition callbacks
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

  # Allow Ransack to search these attributes
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "delivery_date", "id", "order_date", "po_number", "status", "total_amount", "updated_at", "vendor_id", "expected_delivery_date"]
  end

  # Allow Ransack to search these associations
  def self.ransackable_associations(auth_object = nil)
    ["vendor", "purchase_order_items", "created_by", "approved_by"]
  end
end