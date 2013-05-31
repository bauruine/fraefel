class AddLineItemsQuantityToPallets < ActiveRecord::Migration
  def change
    add_column :pallets, :line_items_quantity, :integer, :default => 0
  end
end
