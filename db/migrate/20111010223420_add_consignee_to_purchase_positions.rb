class AddConsigneeToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :consignee_full, :string
  end

  def self.down
    remove_column :purchase_positions, :consignee_full
  end
end
