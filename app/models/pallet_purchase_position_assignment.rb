class PalletPurchasePositionAssignment < ActiveRecord::Base
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
  
  def self.fix_amount_and_weight
    self.all.each do |p_p_p_a|
      if p_p_p_a.purchase_position.present?
        p_p_p_a.update_attributes(:weight => (p_p_p_a.purchase_position.weight_single * p_p_p_a.quantity), :amount => (p_p_p_a.purchase_position.amount * p_p_p_a.quantity))
      end
    end
  end
  
  def self.fix_quantity_for_cargo_list
    self.where("pallets.delivery_rejection_id IS NULL").includes(:pallet).each do |p_p_p_a|
      if p_p_p_a.purchase_position.present?
        p_p_p_a.update_attribute(:reduced_price, (p_p_p_a.purchase_position.amount * p_p_p_a.quantity))
      end
    end
  end
  
end
