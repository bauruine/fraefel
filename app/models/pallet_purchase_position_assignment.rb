class PalletPurchasePositionAssignment < ActiveRecord::Base
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
  
  after_create :update_purchase_position_counter
  after_create :update_purchase_order_calculation
  after_create :update_pallet_level_3
  after_create :update_pallet_zip_location_id
  after_create :update_pallet_shipping_route_id
  after_destroy :update_purchase_position_counter
  after_destroy :handle_assignments
  
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
  
  def update_pallet_shipping_route_id
    if self.pallet.present? && self.purchase_position.present?
      @purchase_orders = self.pallet.purchase_orders
      @shipping_route_id = @purchase_orders.collect(&:shipping_route_id).uniq.compact.first

      self.pallet.update_attribute("shipping_route_id", @shipping_route_id)
    end
  end
  
  def update_pallet_level_3
    if self.pallet.present? && self.purchase_position.present?
      @purchase_orders = self.pallet.purchase_orders
      @level_3_id = @purchase_orders.collect(&:level_3).uniq.compact.first

      self.pallet.update_attribute("level_3", @level_3_id)
    end
  end
  
  def update_pallet_zip_location_id
    if self.pallet.present? && self.purchase_position.present?
      @purchase_positions = self.pallet.purchase_positions
      @zip_location_id = @purchase_positions.collect(&:zip_location_id).uniq.compact.first

      self.pallet.update_attribute("zip_location_id", @zip_location_id)
    end
  end
  
  def update_purchase_position_counter
    if self.pallet.present? && self.purchase_position.present?
      @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.where(:pallet_id => self.pallet.id)
      self.pallet.update_attribute("purchase_position_counter", @pallet_purchase_position_assignments.sum("quantity"))
    end
  end
  
  def update_purchase_order_calculation
    if self.purchase_position.present?
      self.purchase_position.purchase_order.calculation.update_attribute(:total_pallets, self.purchase_position.purchase_order.pallets.count)
    end
  end
  
  def handle_assignments
    if self.pallet.purchase_position_counter == 0
      self.pallet.update_attributes(:cargo_list_id => nil, :delivery_rejection_id => nil)
    end
  end
  
end
