class CreatePurchaseOrders < ActiveRecord::Migration
  def self.up
    create_table :purchase_orders do |t|
      t.integer :customer_id
      t.integer :baan_id

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_orders
  end
end
