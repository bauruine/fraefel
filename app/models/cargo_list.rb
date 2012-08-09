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

  def so_en_michi
      self.pallets.each do |pallet|
        pallet.update_attribute(:delivered, true)
        pallet.purchase_positions.each do |p_p|
          puts "asdfasdf"
          @delivered_p_p_quantity = PalletPurchasePositionAssignment.where(:purchase_position_id => p_p.id).where("pallets.delivered" => true).includes(:pallet).sum(:quantity)
          if p_p.quantity == @delivered_p_p_quantity
            puts "update position"
            p_p.update_attribute(:delivered, true)
          else
            puts "wTFFFFF"
          end
        end
        if !pallet.purchase_positions.where("delivered = false or delivered IS NULL").present?
          
          pallet.purchase_orders.each do |p_o|
            if !p_o.purchase_positions.where("delivered = false or delivered IS NULL").present?
              p_o.update_attribute(:delivered, true)
            end
          end
          
        end
        
      end

  end
  
  private
  
  def change_pallets_status
    if delivered == true
      
      self.pallets.each do |pallet|
        pallet.update_attribute(:delivered, true)
        pallet.purchase_positions.each do |p_p|
          @delivered_p_p_quantity = PalletPurchasePositionAssignment.where(:purchase_position_id => p_p.id).where("pallets.delivered" => true).includes(:pallet).sum(:quantity)
          if p_p.quantity == @delivered_p_p_quantity
            p_p.update_attribute(:delivered, true)
          end
        end
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
