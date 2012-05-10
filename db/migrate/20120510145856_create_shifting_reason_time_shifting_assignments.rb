class CreateShiftingReasonTimeShiftingAssignments < ActiveRecord::Migration
  def self.up
    create_table :shifting_reason_time_shifting_assignments do |t|
      t.integer :time_shifting_id
      t.integer :shifting_reason_id
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :shifting_reason_time_shifting_assignments
  end
end
