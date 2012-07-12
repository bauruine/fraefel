class PurchaseOrderPalletAssignment < ActiveRecord::Base
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  
  belongs_to :purchase_order_only_id, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id", :select => "purchase_orders.id"
end
