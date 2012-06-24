class RemoveStatusFromPurchaseOrders < ActiveRecord::Migration
  def self.up
    remove_column :purchase_orders, :status
  end

  def self.down
    add_column :purchase_orders, :status, :string
  end
end
