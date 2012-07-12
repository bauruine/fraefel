class AddCounterToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :purchase_position_counter, :integer
  end

  def self.down
    remove_column :pallets, :purchase_position_counter
  end
end