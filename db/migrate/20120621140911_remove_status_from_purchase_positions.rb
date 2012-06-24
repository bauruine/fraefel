class RemoveStatusFromPurchasePositions < ActiveRecord::Migration
  def self.up
    remove_column :purchase_positions, :status
  end

  def self.down
    add_column :purchase_positions, :status, :string
  end
end
