class CargoList < ActiveRecord::Base
  has_many :pallets, :class_name => "Pallet", :foreign_key => "cargo_list_id"
  belongs_to :shipper, :class_name => "Shipper", :foreign_key => "shipper_id"
  belongs_to :shipper_location, :class_name => "ShipperLocation", :foreign_key => "shipper_location_id"
  #belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  validates_presence_of :referee
  after_update :change_pallets_status
  
  def additional_space
    additional_space = 0
    pallets.each do |pallet|
      additional_space = additional_space + pallet.additional_space
    end
    return additional_space
  end
  
  def amount
    amount = 0
    purchase_positions.each do |purchase_position|
      amount = amount + purchase_position.amount
    end
    return amount
  end
  
  def weight_total
    weight_total = 0
    purchase_positions.each do |purchase_position|
      weight_total = weight_total + purchase_position.weight_total
    end
    return weight_total
  end
  
  private
  
  def change_pallets_status
    if delivered == true
      Pallet.where(:cargo_list => self).update_all(:delivered => true)
    end
  end
  
end
