class CargoList < ActiveRecord::Base
  has_many :pallets, :class_name => "Pallet", :foreign_key => "cargo_list_id"
end
