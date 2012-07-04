class RemovePurchaseOrderIdFromPallets < ActiveRecord::Migration
  def self.up
    remove_timestamps :pallets
    remove_column :pallets, :purchase_order_id
    remove_column :pallets, :amount
    remove_column :pallets, :delivery_date
    remove_column :pallets, :weight_total
  end

  def self.down
    add_column :pallets, :weight_total, :decimal, :precision => 10, :scale => 0
    add_column :pallets, :delivery_date, :datetime
    add_column :pallets, :amount, :decimal, :precision => 12, :scale => 2
    add_column :pallets, :purchase_order_id, :integer
    add_timestamps :pallets
  end
end
