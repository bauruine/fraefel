class Pallet < ActiveRecord::Base
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "pallet_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
end
