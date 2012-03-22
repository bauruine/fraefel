class AddStockStatusAndProductionStatusAndWorkflowStatusToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :stock_status, :integer, :default => 0
    add_column :purchase_orders, :production_status, :integer, :default => 0
    add_column :purchase_orders, :workflow_status, :string, :default => "00"
  end

  def self.down
    remove_column :purchase_orders, :workflow_status
    remove_column :purchase_orders, :production_status
    remove_column :purchase_orders, :stock_status
  end
end