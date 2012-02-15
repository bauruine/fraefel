class AddRefereeIdToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :referee_id, :integer
  end

  def self.down
    remove_column :addresses, :referee_id
  end
end