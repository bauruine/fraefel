class ChangeQuantityPurchasePositions < ActiveRecord::Migration
  def self.up
    change_column :purchase_positions, :quantity, :integer
  end

  def self.down
    change_column :purchase_positions, :quantity, :float
  end
end
