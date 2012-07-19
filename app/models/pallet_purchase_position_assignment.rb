class PalletPurchasePositionAssignment < ActiveRecord::Base
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
  
  after_create :update_purchase_position_counter
  after_create :update_purchase_order_calculation
  after_destroy :update_purchase_position_counter
  
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
  
  def self.patch_gross_net_value_discount
    self.all.each do |p_p_p_a|
      gross_price = p_p_p_a.purchase_position.gross_price.present? ? p_p_p_a.purchase_position.gross_price : p_p_p_a.purchase_position.amount
      net_price = p_p_p_a.purchase_position.net_price.present? ? p_p_p_a.purchase_position.net_price : p_p_p_a.purchase_position.amount
      value_discount = p_p_p_a.purchase_position.value_discount.present? ? p_p_p_a.purchase_position.value_discount : 0
      p_p_p_a.update_attributes(:gross_price => gross_price, :net_price => net_price, :value_discount => value_discount)
    end
  end
  
  def self.patch_pallet_purchase_position_counter
    self.select("DISTINCT `pallet_purchase_position_assignments`.*").joins(:pallet, :purchase_position).readonly(false).each do |pallet_purchase_position_assignment|
      pallet_purchase_position_assignment.pallet.update_attribute("purchase_position_counter", pallet_purchase_position_assignment.quantity)
    end
  end

  private
  
  def update_purchase_position_counter
    @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.where(:pallet_id => self.pallet.id)
    self.pallet.update_attribute("purchase_position_counter", @pallet_purchase_position_assignments.sum("quantity"))
  end
  
  def update_purchase_order_calculation
    self.purchase_position.purchase_order.calculation.update_attribute(:total_pallets, self.purchase_position.purchase_order.pallets.count)
  end
  
end
