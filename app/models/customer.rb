class Customer < ActiveRecord::Base
  validates_presence_of :company
  has_many :shipping_addresses, :class_name => "ShippingAddress", :foreign_key => "customer_id"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :foreign_key => "customer_id"
  accepts_nested_attributes_for :shipping_addresses
  has_paper_trail :on => [:update]
  
  def simplified
    self.company.downcase.delete(' ')
  end
end
