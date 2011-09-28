class CargoList < ActiveRecord::Base
  has_many :pallets, :class_name => "Pallet", :foreign_key => "cargo_list_id"
  belongs_to :shipper, :class_name => "Shipper", :foreign_key => "shipper_id"
  belongs_to :shipper_location, :class_name => "ShipperLocation", :foreign_key => "shipper_location_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
end
