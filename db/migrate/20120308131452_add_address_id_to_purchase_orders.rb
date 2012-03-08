class AddAddressIdToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :address_id, :integer
  end

  def self.down
    remove_column :purchase_orders, :address_id
  end
end