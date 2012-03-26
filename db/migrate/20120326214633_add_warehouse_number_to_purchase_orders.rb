class AddWarehouseNumberToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :warehouse_number, :integer, :default => 0
  end

  def self.down
    remove_column :purchase_orders, :warehouse_number
  end
end