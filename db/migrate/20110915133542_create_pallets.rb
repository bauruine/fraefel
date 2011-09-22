class CreatePallets < ActiveRecord::Migration
  def self.up
    create_table :pallets do |t|
      t.integer :purchase_order_id
      t.integer :cargo_list_id
      t.decimal :amount
      t.decimal :weight_total
      t.datetime :delivery_date

      t.timestamps
    end
  end

  def self.down
    drop_table :pallets
  end
end
