class AddLevel1AndLevel2AndLevel3OnPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :level_1, :integer
    add_column :purchase_orders, :level_2, :integer
    add_column :purchase_orders, :level_3, :integer
  end

  def self.down
    remove_column :purchase_orders, :level_3
    remove_column :purchase_orders, :level_2
    remove_column :purchase_orders, :level_1
  end
end