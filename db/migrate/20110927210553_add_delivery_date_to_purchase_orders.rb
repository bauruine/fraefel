class AddDeliveryDateToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :delivery_date, :date
  end

  def self.down
    remove_column :purchase_orders, :delivery_date
  end
end
