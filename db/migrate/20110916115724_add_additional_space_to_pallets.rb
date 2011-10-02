class AddAdditionalSpaceToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :additional_space, :decimal, :default => 0
  end

  def self.down
    remove_column :pallets, :additional_space
  end
end
