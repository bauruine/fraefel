class ChangeColumnAdditionalSpaceOnPallets < ActiveRecord::Migration
  def self.up
    change_column :pallets, :additional_space, :float
  end

  def self.down
    change_column :pallets, :additional_space, :integer
  end
end
