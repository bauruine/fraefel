class AddPriorityLevelToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :priority_level, :integer, :default => 0
  end

  def self.down
    remove_column :purchase_orders, :priority_level
  end
end