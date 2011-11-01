class AddZipLocationIdAndZipLocationNameToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :zip_location_id, :integer
    add_column :purchase_positions, :zip_location_name, :string
  end

  def self.down
    remove_column :purchase_positions, :zip_location_id
    remove_column :purchase_positions, :zip_location_name
  end
end
