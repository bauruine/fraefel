class AddShippingRouteIdToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :shipping_route_id, :integer
  end

  def self.down
    remove_column :pallets, :shipping_route_id
  end
end
