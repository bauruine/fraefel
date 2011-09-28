class AddDeliveryRouteToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :shipping_route_id, :integer
  end

  def self.down
    remove_column :purchase_orders, :shipping_route_id
  end
end
