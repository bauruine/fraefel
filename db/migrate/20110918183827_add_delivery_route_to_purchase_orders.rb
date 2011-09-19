class AddDeliveryRouteToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :delivery_route, :string
    add_column :purchase_orders, :delivery_route_id, :integer
  end

  def self.down
    remove_column :purchase_orders, :delivery_route_id
    remove_column :purchase_orders, :delivery_route
  end
end
