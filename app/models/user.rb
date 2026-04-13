class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :created_purchase_orders, class_name: 'PurchaseOrder', foreign_key: 'created_by_id'
  has_many :approved_purchase_orders, class_name: 'PurchaseOrder', foreign_key: 'approved_by_id'

  # Role-based attributes
  attribute :admin, :boolean, default: false
  attribute :approver, :boolean, default: false
  attribute :procurement_officer, :boolean, default: false

  # Role methods using modern syntax
  def admin? = admin
  def approver? = approver
  def procurement_officer? = procurement_officer

  # Scopes using modern syntax
  scope :admins, -> { where(admin: true) }
  scope :approvers, -> { where(approver: true) }
  scope :procurement_officers, -> { where(procurement_officer: true) }
end
