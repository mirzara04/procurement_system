class VendorRating < ApplicationRecord
  belongs_to :vendor
  belongs_to :user
  belongs_to :purchase_order

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :category, presence: true
  validates :vendor_id, uniqueness: { scope: :purchase_order_id, message: "has already been rated for this purchase order" }
  
  before_save :set_rating_date

  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :by_category, ->(category) { where(category: category) }

  private

  def set_rating_date
    self.rating_date = Time.current unless rating_date
  end
end 