class AddCategoryIdToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :category_id, :integer
  end

  def self.down
    remove_column :purchase_orders, :category_id
  end
end