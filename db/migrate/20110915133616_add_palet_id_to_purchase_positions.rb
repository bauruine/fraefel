class AddPaletIdToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :pallet_id, :integer
  end

  def self.down
    remove_column :purchase_positions, :pallet_id
  end
end
