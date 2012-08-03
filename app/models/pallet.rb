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

  def self.patch_purchase_orders
    where("purchase_orders.id IS NULL").includes(:purchase_orders).each do |pallet|
      @purchase_orders_array = Array.new
      pallet.purchase_positions.each do |purchase_position|
        @purchase_orders_array << purchase_position.purchase_order
      end
      puts @purchase_orders_array.size
      pallet.purchase_orders += @purchase_orders_array.uniq!
    end
  end
  
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
  
  def self.patch_level_3
    self.select("DISTINCT `pallets`.*").joins(:purchase_orders, :purchase_positions).readonly(false).each do |pallet|
      @purchase_orders = pallet.purchase_orders
      @level_3_id = @purchase_orders.collect(&:level_3).uniq.compact.first

      pallet.update_attribute("level_3", @level_3_id)
    end
  end
  
  def self.patch_zip_location_id
    self.select("DISTINCT `pallets`.*").joins(:purchase_orders, :purchase_positions).readonly(false).each do |pallet|
      @purchase_positions = pallet.purchase_positions
      @zip_location_id = @purchase_positions.collect(&:zip_location_id).uniq.compact.first

      pallet.update_attribute("zip_location_id", @zip_location_id)
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
