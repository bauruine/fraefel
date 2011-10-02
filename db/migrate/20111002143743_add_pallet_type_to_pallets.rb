class AddPalletTypeToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :pallet_type_id, :integer
  end

  def self.down
    remove_column :pallets, :pallet_type_id
  end
end
