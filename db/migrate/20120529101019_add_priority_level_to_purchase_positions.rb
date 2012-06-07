class AddPriorityLevelToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :priority_level, :integer, :default => 1
  end

  def self.down
    remove_column :purchase_positions, :priority_level
  end
end