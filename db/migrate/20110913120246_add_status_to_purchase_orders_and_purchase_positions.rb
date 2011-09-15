class AddStatusToPurchaseOrdersAndPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :status, :string
    add_column :purchase_positions, :status, :string
  end

  def self.down
    remove_column :purchase_orders, :status
    remove_column :purchase_positions, :status
  end
end
