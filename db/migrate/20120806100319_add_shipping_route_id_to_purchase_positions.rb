class AddShippingRouteIdToPurchasePositions < ActiveRecord::Migration

  def change
    add_column :purchase_positions, :shipping_route_id, :integer
  end
  
end
