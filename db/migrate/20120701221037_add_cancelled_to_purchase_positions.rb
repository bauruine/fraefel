class AddCancelledToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :cancelled, :boolean, :default => false
  end

  def self.down
    remove_column :purchase_positions, :cancelled
  end
end