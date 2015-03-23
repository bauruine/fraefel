class AddZipLocationIdToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :zip_location_id, :integer
    add_index :purchase_orders, :zip_location_id
  end
end
