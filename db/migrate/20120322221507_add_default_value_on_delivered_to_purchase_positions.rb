class AddDefaultValueOnDeliveredToPurchasePositions < ActiveRecord::Migration
  def self.up
    change_column_default :purchase_positions, :delivered, false
  end

  def self.down
    change_column_default :purchase_positions, :delivered, nil
  end
end