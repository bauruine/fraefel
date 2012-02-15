class AddDeliveryRejectionIdToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :delivery_rejection_id, :integer
  end

  def self.down
    remove_column :addresses, :delivery_rejection_id
  end
end