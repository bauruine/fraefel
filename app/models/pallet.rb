class Pallet < ActiveRecord::Base
  belongs_to :cargo_list, :class_name => "CargoList", :foreign_key => "cargo_list_id", :counter_cache => true
  belongs_to :pallet_type, :class_name => "PalletType", :foreign_key => "pallet_type_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "level_3"
  belongs_to :zip_location, :class_name => "ZipLocation", :foreign_key => "zip_location_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  
  has_many :purchase_order_pallet_assignments, :class_name => "PurchaseOrderPalletAssignment"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :through => :purchase_order_pallet_assignments
  
  has_many :pallet_purchase_position_assignments, :class_name => "PalletPurchasePositionAssignment"
  has_many :purchase_positions, :class_name => "PurchasePosition", :through => :pallet_purchase_position_assignments
  
  belongs_to :delivery_rejection, :class_name => "DeliveryRejection", :foreign_key => "delivery_rejection_id"
  after_create :assign_default_pallet_type

  def self.patch_pallets
    Pallet.all.each do |pallet|
      p_o_ids = Array.new
      pallet.purchase_positions.each do |p_p|
        p_o_ids << p_p.purchase_order.id
      end
      purchase_orders_array = PurchaseOrder.where(:id => p_o_ids)
      pallet.purchase_orders += purchase_orders_array
    end
  end
  
  def self.patch_shipping_route_id
    self.select("DISTINCT `pallets`.*").joins(:purchase_orders, :purchase_positions).readonly(false).each do |pallet|
      @purchase_orders = pallet.purchase_orders
      @shipping_route_id = @purchase_orders.collect(&:shipping_route_id).uniq.compact.first

      pallet.update_attribute("shipping_route_id", @shipping_route_id)
    end
  end

  def self.patch_pallet_purchase_position_assignments
    Pallet.all.each do |pallet|
      p_p_ids = Array.new
      pallet.old_purchase_positions.each do |p_p|
        p_p_ids << p_p.id
      end
      purchase_positions_array = PurchasePosition.where(:id => p_p_ids)
      pallet.purchase_positions += purchase_positions_array
    end
  end
  
  def self.patch_pallet_purchase_position_assignments_quantity
    PalletPurchasePositionAssignment.all.each do |p_p_p_a|
      @p_p = PurchasePosition.find(p_p_p_a.purchase_position_id)
      p_p_p_a.update_attribute(:quantity, @p_p.quantity)
    end
  end
  
  protected
  
  def assign_default_pallet_type
    update_attributes(:pallet_type => PalletType.find_by_description("ganz"))
  end
end
