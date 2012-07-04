class RemoveTimeStampsFromAddresses < ActiveRecord::Migration
  def self.up
    remove_timestamps :addresses
  end

  def self.down
    add_timestamps :addresses
  end
end