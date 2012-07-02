class AddCancelledToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :cancelled, :boolean, :default => false
  end

  def self.down
    remove_column :purchase_orders, :cancelled
  end
end