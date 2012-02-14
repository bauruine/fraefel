class AddAmountAndWeightToPalletPurchasePositionAssignments < ActiveRecord::Migration
  def self.up
    add_column :pallet_purchase_position_assignments, :amount, :decimal, :precision => 12, :scale => 2
    add_column :pallet_purchase_position_assignments, :weight, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :pallet_purchase_position_assignments, :weight
    remove_column :pallet_purchase_position_assignments, :amount
  end
end