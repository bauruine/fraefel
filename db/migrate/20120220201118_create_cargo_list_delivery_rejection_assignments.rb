class CreateCargoListDeliveryRejectionAssignments < ActiveRecord::Migration
  def self.up
    create_table :cargo_list_delivery_rejection_assignments do |t|
      t.integer :delivery_rejection_id
      t.integer :cargo_list_id

      t.timestamps
    end
  end

  def self.down
    drop_table :cargo_list_delivery_rejection_assignments
  end
end
