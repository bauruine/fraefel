class Pallet < ActiveRecord::Base
  belongs_to :cargo_list, :class_name => "CargoList", :foreign_key => "cargo_list_id"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "pallet_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
end
