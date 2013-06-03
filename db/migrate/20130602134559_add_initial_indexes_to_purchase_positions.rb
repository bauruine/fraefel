class AddInitialIndexesToPurchasePositions < ActiveRecord::Migration
  def change
    add_index :purchase_positions, :baan_id, :unique => true
    add_index :purchase_positions, :commodity_code_id
    add_index :purchase_positions, :shipping_route_id
    add_index :purchase_positions, :zip_location_id
    add_index :purchase_positions, :level_3
    add_index :purchase_positions, :storage_location
  end
end
