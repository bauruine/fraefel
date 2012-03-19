class PurchaseOrderAddressAssignment < ActiveRecord::Base
  belongs_to :address, :class_name => "Address", :foreign_key => "address_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
end
