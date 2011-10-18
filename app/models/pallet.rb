class Pallet < ActiveRecord::Base
  belongs_to :cargo_list, :class_name => "CargoList", :foreign_key => "cargo_list_id"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "pallet_id"
  belongs_to :old_purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :pallet_type, :class_name => "PalletType", :foreign_key => "pallet_type_id"
  has_many :purchase_order_pallet_assignments, :class_name => "PurchaseOrderPalletAssignment"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :through => :purchase_order_pallet_assignments
  after_create :assign_default_pallet_type
  
  
  def mixed?
    self.purchase_orders.group("purchase_orders.id").count.size > 1 ? true : false
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
  
  protected
  
  def assign_default_pallet_type
    update_attributes(:pallet_type => PalletType.find_by_description("ganz"))
  end
end
