class CreatePurchasePositions < ActiveRecord::Migration
  def self.up
    create_table :purchase_positions do |t|
      t.integer :purchase_order_id
      t.integer :commodity_code_id
      t.decimal :weight_single, :scale => 2
      t.decimal :weight_total, :scale => 2
      t.decimal :quantity, :scale => 2
      t.decimal :amount, :scale => 2
      t.datetime :delivery_date

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_positions
  end
end
