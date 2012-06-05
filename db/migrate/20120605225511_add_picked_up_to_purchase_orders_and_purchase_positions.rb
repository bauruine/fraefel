class AddPickedUpToPurchaseOrdersAndPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :picked_up, :boolean, :default => false
    add_column :purchase_positions, :picked_up, :boolean, :default => false
  end

  def self.down
    remove_column :purchase_positions, :picked_up
    remove_column :purchase_orders, :picked_up
  end
end