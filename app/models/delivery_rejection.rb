# encoding: utf-8 
class DeliveryRejection < ActiveRecord::Base
  belongs_to :status, :class_name => "Status", :foreign_key => "status_id"
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  
  has_many :comments, :as => :commentable  
  
  has_many :transport_issues
  has_many :purchase_positions, :through => :transport_issues, :foreign_key => "purchase_position_id", :source => :purchase_position
  
  accepts_nested_attributes_for :comments
  
  validates_presence_of :category, :message => "Es wurde kein Grund angegeben"
  validates_presence_of :status, :message => "Es wurde kein Status gewählt"
  validates_presence_of :customer_company, :message => "Es wurde kein Handelspartner angegeben"
  validates_presence_of :purchase_positions, :message => "Es wurden keine VK-Positionen hinzugefügt"
  
  def customer_company
    customer.try(:company)
  end

  def customer_company=(name)
    self.customer = Customer.find_by_company(name) if name.present?
  end
  
end
