class CreatePurchaseOrderAddressAssignments < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_address_assignments do |t|
      t.integer :purchase_order_id
      t.integer :address_id

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_address_assignments
  end
end
