class AddColumnDeliveredToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :delivered, :boolean
  end

  def self.down
    remove_column :purchase_positions, :delivered
  end
end
