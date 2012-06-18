class AddPendingStatusToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :pending_status, :integer, :default => 0
  end

  def self.down
    remove_column :purchase_orders, :pending_status
  end
end