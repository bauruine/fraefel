class RemoveTimeStampsFromPalletTypes < ActiveRecord::Migration
  def self.up
    remove_timestamps :pallet_types
  end

  def self.down
    add_timestamps :pallet_types
  end
end