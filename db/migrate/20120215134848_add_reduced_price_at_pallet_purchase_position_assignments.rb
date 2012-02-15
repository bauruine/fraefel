class AddReducedPriceAtPalletPurchasePositionAssignments < ActiveRecord::Migration
  def self.up
    add_column :pallet_purchase_position_assignments, :reduced_price, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :pallet_purchase_position_assignments, :reduced_price
  end
end