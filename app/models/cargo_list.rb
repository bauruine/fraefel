class CargoList < ActiveRecord::Base
  has_many :pallets, :class_name => "Pallet", :foreign_key => "cargo_list_id"
  belongs_to :shipper, :class_name => "Shipper", :foreign_key => "shipper_id"
  belongs_to :shipper_location, :class_name => "ShipperLocation", :foreign_key => "shipper_location_id"
  #belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  validates_presence_of :referee
  after_update :change_pallets_status
  
  def additional_space
    additional_space = 0.to_f
    pallets.each do |pallet|
      additional_space = additional_space + (pallet.additional_space.present? ? pallet.additional_space : pallet.additional_space.to_f)
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
      PurchasePosition.where("cargo_lists.id = #{self.id}").includes(:pallet => :cargo_list).each do |p_p|
        p_p.update_attribute(:delivered, true)
      end
      
      self.pallets.each do |pallet|
        
        if !pallet.purchase_positions.where("delivered = false or delivered IS NULL").present?
          
          pallet.purchase_orders.each do |p_o|
            if !p_o.purchase_positions.where("delivered = false or delivered IS NULL").present?
              p_o.update_attribute(:delivered, true)
            end
          end
          
        end
        
      end
      
    end
  end
  
end
