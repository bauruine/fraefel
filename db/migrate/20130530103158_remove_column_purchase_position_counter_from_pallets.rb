class RemoveColumnPurchasePositionCounterFromPallets < ActiveRecord::Migration
  def up
    remove_column :pallets, :purchase_position_counter
  end

  def down
    add_column :pallets, :purchase_position_counter, :integer, :default => 0
  end
end