class AddPositionToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :position, :integer
  end

  def self.down
    remove_column :purchase_positions, :position
  end
end
