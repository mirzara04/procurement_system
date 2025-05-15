class PurchaseOrder < ApplicationRecord
  include PaperTrail::Model

  PAYMENT_TERMS = [
    'Net 30',
    'Net 45',
    'Net 60',
    'Due on Receipt',
    'Due End of Month',
    'Cash on Delivery'
  ].freeze

  CURRENCIES = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD'
  ].freeze

  belongs_to :vendor
  belongs_to :created_by, class_name: 'User'
  belongs_to :approved_by, class_name: 'User', optional: true

  has_many :purchase_order_items, dependent: :destroy
  has_many :vendor_ratings, dependent: :destroy

  accepts_nested_attributes_for :purchase_order_items, 
    reject_if: :all_blank, 
    allow_destroy: true

  validates :po_number, presence: true, uniqueness: true
  validates :vendor_id, :expected_delivery_date, :shipping_address, presence: true
  validates :status, presence: true
  validates :payment_terms, inclusion: { in: PAYMENT_TERMS }, allow_nil: true
  validates :currency, inclusion: { in: CURRENCIES }
  validate :expected_delivery_date_cannot_be_in_past, on: :create
  validate :must_have_at_least_one_item

  before_validation :generate_po_number, on: :create
  before_save :calculate_total_amount

  enum status: {
    draft: 0,
    pending_approval: 1,
    approved: 2,
    rejected: 3,
    cancelled: 4,
    in_progress: 5,
    delivered: 6
  }

  scope :pending_approval, -> { where(status: :pending_approval) }
  scope :approved, -> { where(status: :approved) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :delivered, -> { where(status: :delivered) }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }
  scope :by_vendor, ->(vendor_id) { where(vendor_id: vendor_id) }

  def can_be_deleted?
    draft?
  end

  def can_be_cancelled?
    !cancelled? && !delivered? && !draft?
  end

  def submit_for_approval
    return false unless draft?
    
    transaction do
      update!(status: :pending_approval)
      # Send notification to approvers
      PurchaseOrderMailer.approval_request(self).deliver_later
      true
    end
  rescue StandardError => e
    errors.add(:base, "Failed to submit for approval: #{e.message}")
    false
  end

  def approve(user)
    return false unless pending_approval?
    
    transaction do
      self.approved_by = user
      self.approved_at = Time.current
      self.status = :approved
      save!
      
      # Send notification to creator
      PurchaseOrderMailer.approved_notification(self).deliver_later
      true
    end
  rescue StandardError => e
    errors.add(:base, "Failed to approve: #{e.message}")
    false
  end

  def reject(user, reason = nil)
    return false unless pending_approval?
    
    transaction do
      self.status = :rejected
      self.rejection_reason = reason
      self.rejected_by = user
      self.rejected_at = Time.current
      save!
      
      # Send notification to creator
      PurchaseOrderMailer.rejected_notification(self).deliver_later
      true
    end
  rescue StandardError => e
    errors.add(:base, "Failed to reject: #{e.message}")
    false
  end

  def cancel(user)
    return false unless can_be_cancelled?
    
    transaction do
      self.status = :cancelled
      self.cancelled_by = user
      self.cancelled_at = Time.current
      save!
      
      # Send notification
      PurchaseOrderMailer.cancelled_notification(self).deliver_later
      true
    end
  rescue StandardError => e
    errors.add(:base, "Failed to cancel: #{e.message}")
    false
  end

  def mark_as_delivered(delivery_date = nil)
    return false unless approved? || in_progress?
    
    transaction do
      self.status = :delivered
      self.actual_delivery_date = delivery_date || Time.current
      save!
      
      # Send notification
      PurchaseOrderMailer.delivery_notification(self).deliver_later
      true
    end
  rescue StandardError => e
    errors.add(:base, "Failed to mark as delivered: #{e.message}")
    false
  end

  private

  def generate_po_number
    return if po_number.present?
    
    last_po = PurchaseOrder.order(created_at: :desc).first
    last_number = last_po&.po_number&.match(/\d+/)&.[](0).to_i || 0
    
    self.po_number = format('PO%07d', last_number + 1)
  end

  def calculate_total_amount
    self.total_amount = purchase_order_items.sum do |item|
      item.quantity * item.unit_price
    end
  end

  def expected_delivery_date_cannot_be_in_past
    if expected_delivery_date.present? && expected_delivery_date < Date.current
      errors.add(:expected_delivery_date, "can't be in the past")
    end
  end

  def must_have_at_least_one_item
    if purchase_order_items.empty? || purchase_order_items.all?(&:marked_for_destruction?)
      errors.add(:base, "Must have at least one item")
    end
  end
end
