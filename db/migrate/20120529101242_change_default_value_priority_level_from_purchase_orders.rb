class ChangeDefaultValuePriorityLevelFromPurchaseOrders < ActiveRecord::Migration
  def self.up
    change_column_default :purchase_orders, :priority_level, 1
  end

  def self.down
    change_column_default :purchase_orders, :priority_level, 0
  end
end