class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  
  # Associations
  has_many :created_purchase_orders, class_name: 'PurchaseOrder', foreign_key: 'created_by_id'
  has_many :approved_purchase_orders, class_name: 'PurchaseOrder', foreign_key: 'approved_by_id'
  has_many :vendor_ratings
  has_many :uploaded_vendor_documents, class_name: 'VendorDocument', foreign_key: 'uploaded_by_id'

  # Role methods
  def admin?
    admin == true
  end
  
  def approver?
    approver == true
  end

  def procurement_officer?
    !admin? && !approver?
  end

  private

  def password_required?
    new_record? ? super : false
  end
end
