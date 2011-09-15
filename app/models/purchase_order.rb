class PurchaseOrder < ActiveRecord::Base
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "purchase_order_id"
end
