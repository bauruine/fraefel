class AddDeliveredStatusToPurchaseOrdersAndCargoLists < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :delivered, :boolean, :default => false
    add_column :cargo_lists, :delivered, :boolean, :default => false
    add_column :pallets, :delivered, :boolean, :default => false
  end

  def self.down
    remove_column :purchase_orders, :delivered
    remove_column :cargo_lists, :delivered
    remove_column :pallets, :delivered
  end
end
