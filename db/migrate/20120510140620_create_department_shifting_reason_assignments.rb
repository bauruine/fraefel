class CreateDepartmentShiftingReasonAssignments < ActiveRecord::Migration
  def self.up
    create_table :department_shifting_reason_assignments do |t|
      t.integer :department_id
      t.integer :shifting_reason_id
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :department_shifting_reason_assignments
  end
end
