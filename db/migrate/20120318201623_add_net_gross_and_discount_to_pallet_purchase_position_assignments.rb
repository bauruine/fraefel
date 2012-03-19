class AddNetGrossAndDiscountToPalletPurchasePositionAssignments < ActiveRecord::Migration
  def self.up
    add_column :pallet_purchase_position_assignments, :gross_price, :decimal, :precision => 12, :scale => 2
    add_column :pallet_purchase_position_assignments, :net_price, :decimal, :precision => 12, :scale => 2
    add_column :pallet_purchase_position_assignments, :value_discount, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :pallet_purchase_position_assignments, :value_discount
    remove_column :pallet_purchase_position_assignments, :net_price
    remove_column :pallet_purchase_position_assignments, :gross_price
  end
end
