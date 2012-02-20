class CargoListDeliveryRejectionAssignment < ActiveRecord::Base
  belongs_to :cargo_list, :class_name => "CargoList", :foreign_key => "cargo_list_id"
  belongs_to :delivery_rejection, :class_name => "DeliveryRejection", :foreign_key => "delivery_rejection_id"
end
