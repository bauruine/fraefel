class AddAddressAdditionalsToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :additional_1, :string, :limit => 50
    add_column :purchase_orders, :additional_2, :string, :limit => 50
    add_column :purchase_orders, :additional_3, :string, :limit => 50
  end
end
