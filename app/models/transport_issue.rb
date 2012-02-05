class TransportIssue < ActiveRecord::Base
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
  belongs_to :delivery_rejection, :class_name => "DeliveryRejection", :foreign_key => "delivery_rejection_id"
end
