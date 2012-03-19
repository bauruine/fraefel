class AddNetGrossAndDiscountToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :gross_price, :decimal, :precision => 12, :scale => 2
    add_column :purchase_positions, :net_price, :decimal, :precision => 12, :scale => 2
    add_column :purchase_positions, :value_discount, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :purchase_positions, :value_discount
    remove_column :purchase_positions, :net_price
    remove_column :purchase_positions, :gross_price
  end
end