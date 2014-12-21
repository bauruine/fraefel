class AddAddressAdditionalsToPurchasePositions < ActiveRecord::Migration
  def change
    add_column :purchase_positions, :additional_1, :string, :limit => 50
    add_column :purchase_positions, :additional_2, :string, :limit => 50
    add_column :purchase_positions, :additional_3, :string, :limit => 50
  end
end
