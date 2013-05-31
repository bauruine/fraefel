class Pallet < ActiveRecord::Base
  belongs_to :cargo_list, :class_name => "CargoList", :foreign_key => "cargo_list_id", :counter_cache => true
  belongs_to :pallet_type, :class_name => "PalletType", :foreign_key => "pallet_type_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "level_3"
  belongs_to :zip_location, :class_name => "ZipLocation", :foreign_key => "zip_location_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  
  has_many :purchase_order_pallet_assignments, :class_name => "PurchaseOrderPalletAssignment"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :through => :purchase_order_pallet_assignments
  
  has_many :line_items, :class_name => "PalletPurchasePositionAssignment"
  has_many :pallet_purchase_position_assignments, :class_name => "PalletPurchasePositionAssignment"
  has_many :purchase_positions, :class_name => "PurchasePosition", :through => :pallet_purchase_position_assignments
  
  belongs_to :delivery_rejection, :class_name => "DeliveryRejection", :foreign_key => "delivery_rejection_id"
  
  before_create :assign_default_pallet_type
  # after_create  :assign_shipping_address, :assign_zip_location, :assign_shipping_route
  
  def self.patch_purchase_orders
    where("purchase_orders.id IS NULL").includes(:purchase_orders).each do |pallet|
      @purchase_orders_array = Array.new
      pallet.purchase_positions.each do |purchase_position|
        @purchase_orders_array << purchase_position.purchase_order
      end
      puts @purchase_orders_array.size
      pallet.purchase_orders += @purchase_orders_array.uniq
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
    self.joins(:line_items).uniq.readonly(false).each do |pallet|
      pallet.patch_shipping_route_id
    end
  end
  
  def self.patch_shipping_address
    self.joins(:line_items).uniq.readonly(false).each do |pallet|
      pallet.patch_shipping_address
    end
  end
  
  def self.patch_zip_location_id
    self.joins(:line_items).uniq.readonly(false).each do |pallet|
      pallet.patch_zip_location_id
    end
  end
  
  def patch_shipping_route_id
    if self.purchase_positions.present?
      self.update_column(:shipping_route_id, self.purchase_positions.collect(&:shipping_route_id).uniq.sample)
    end
  end
  
  def patch_shipping_address
    if self.purchase_positions.present?
      self.update_column(:level_3, self.purchase_positions.collect(&:level_3).uniq.sample)
    end
  end
  
  def patch_zip_location_id
    if self.purchase_positions.present?
      self.update_column(:zip_location_id, self.purchase_positions.collect(&:zip_location_id).uniq.sample)
    end
  end
  
  def self.recalculate_line_items_quantity
    Pallet.where(:line_items_quantity => 0).each do |pallet|
      pallet.recalculate_line_items_quantity
    end
  end
  
  def recalculate_line_items_quantity
    self.update_column(:line_items_quantity, self.line_items.sum(:quantity))
  end
  
  def destroy_if_no_line_items
    if self.line_items.count == 0
      self.destroy
    end
  end
  
  protected
  
  def assign_default_pallet_type
    if self.pallet_type_id.nil?
      self.pallet_type_id = PalletType.where(:description => "ganz").first.try(:id)
    end
  end
  
  def assign_shipping_address
    self.reload
    if self.level_3.nil?
      if self.purchase_positions.present?
        self.update_column(:level_3, self.purchase_positions.collect(&:level_3).uniq.sample)
      end
    end
  end
  
  def assign_zip_location
    self.reload
    if self.zip_location_id.nil?
      if self.purchase_positions.present?
        self.update_column(:zip_location_id, self.purchase_positions.collect(&:zip_location_id).uniq.sample)
      end
    end
  end
  
  def assign_shipping_route
    self.reload
    if self.shipping_route_id.nil?
      if self.purchase_positions.present?
        self.update_column(:shipping_route_id, self.purchase_positions.collect(&:shipping_route_id).uniq.sample)
      end
    end
  end
  
end
