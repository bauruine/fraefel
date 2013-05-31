class PalletPurchasePositionAssignment < ActiveRecord::Base
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"

  after_save :recalculate_pallet_line_items_quantity
  after_destroy :recalculate_pallet_line_items_quantity, :destroy_pallet_if_no_line_items
  
  after_save :update_pallet_shipping_address, :update_pallet_zip_location_id, :update_pallet_shipping_route_id
  
  after_create :update_purchase_order_calculation
  
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

  def update_pallet_shipping_route_id
    self.reload
    self.pallet.patch_shipping_route_id
  end

  def update_pallet_shipping_address
    self.reload
    self.pallet.patch_shipping_address
  end

  def update_pallet_zip_location_id
    self.reload
    self.pallet.patch_zip_location_id
  end

  def recalculate_pallet_line_items_quantity
    #self.reload
    self.pallet.recalculate_line_items_quantity
  end

  def update_purchase_order_calculation
    if self.purchase_position.present?
      self.purchase_position.purchase_order.calculation.update_attribute(:total_pallets, self.purchase_position.purchase_order.pallets.count)
    end
  end

  def destroy_pallet_if_no_line_items
    self.pallet.destroy_if_no_line_items
  end

  def very_ugly_patcher
    self.recalculate_pallet_line_items_quantity
    self.update_purchase_order_calculation
    self.update_pallet_shipping_address
    self.update_pallet_zip_location_id
    self.update_pallet_shipping_route_id
  end
end
