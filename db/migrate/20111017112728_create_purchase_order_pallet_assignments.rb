class CreatePurchaseOrderPalletAssignments < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_pallet_assignments do |t|
      t.integer :purchase_order_id
      t.integer :pallet_id

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_pallet_assignments
  end
end
