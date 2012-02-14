class AddDeliveryRejectionIdToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :delivery_rejection_id, :integer
  end

  def self.down
    remove_column :pallets, :delivery_rejection_id
  end
end