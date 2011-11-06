class PalletPurchasePositionAssignment < ActiveRecord::Base
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
end
