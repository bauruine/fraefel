class CreatePalletPurchasePositionAssignments < ActiveRecord::Migration
  def self.up
    create_table :pallet_purchase_position_assignments do |t|
      t.integer :pallet_id
      t.integer :purchase_position_id
      t.integer :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :pallet_purchase_position_assignments
  end
end
