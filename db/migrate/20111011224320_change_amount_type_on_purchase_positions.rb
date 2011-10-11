class ChangeAmountTypeOnPurchasePositions < ActiveRecord::Migration
  def self.up
    change_column :purchase_positions, :amount, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    change_column :purchase_positions, :amount, :decimal, :precision => 10, :scale => 0
  end
end
