class AddPalletsCounterCacheOnCargoLists < ActiveRecord::Migration
  def self.up
    add_column :cargo_lists, :pallets_count, :integer, :default => 0
    
    CargoList.reset_column_information
    
    CargoList.all.each do |cargo_list|
      CargoList.update_counters cargo_list.id, :pallets_count => cargo_list.pallets.length
    end
  end

  def self.down
    remove_column :cargo_lists, :pallets_count
  end
end
