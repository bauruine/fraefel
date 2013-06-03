class AddInitialIndexesToPurchaseOrders < ActiveRecord::Migration
  def change
    add_index :purchase_orders, :baan_id, :unique => true

    add_index :purchase_orders, :shipping_route_id
    add_index :purchase_orders, :category_id

    add_index :purchase_orders, :level_1
    add_index :purchase_orders, :level_2
    add_index :purchase_orders, :level_3

    add_index :purchase_orders, :stock_status
    add_index :purchase_orders, :production_status
    add_index :purchase_orders, :warehouse_number

    add_index :purchase_orders, :priority_level
    add_index :purchase_orders, :pending_status

    add_index :purchase_orders, :delivered
    add_index :purchase_orders, :picked_up
    add_index :purchase_orders, :cancelled
  end
end
