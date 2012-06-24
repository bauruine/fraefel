class RemoveZipLocationNameFromPurchasePositions < ActiveRecord::Migration
  def self.up
    remove_column :purchase_positions, :zip_location_name
  end

  def self.down
    add_column :purchase_positions, :zip_location_name, :string
  end
end
