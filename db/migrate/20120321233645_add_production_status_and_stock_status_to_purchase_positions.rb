class AddProductionStatusAndStockStatusToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :production_status, :integer, :default => 0
    add_column :purchase_positions, :stock_status, :integer, :default => 0
  end

  def self.down
    remove_column :purchase_positions, :stock_status
    remove_column :purchase_positions, :production_status
  end
end