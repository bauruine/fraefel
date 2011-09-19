class AddProductToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :product_line, :string
    add_column :purchase_positions, :article, :string
  end

  def self.down
    remove_column :purchase_positions, :product_line
    remove_column :purchase_positions, :article
  end
end
