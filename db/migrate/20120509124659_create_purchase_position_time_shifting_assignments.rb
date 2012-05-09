class CreatePurchasePositionTimeShiftingAssignments < ActiveRecord::Migration
  def self.up
    create_table :purchase_position_time_shifting_assignments do |t|
      t.integer :purchase_position_id
      t.integer :time_shifting_id
      t.boolean :considered
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_position_time_shifting_assignments
  end
end
