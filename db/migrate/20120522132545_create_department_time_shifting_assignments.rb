class CreateDepartmentTimeShiftingAssignments < ActiveRecord::Migration
  def self.up
    create_table :department_time_shifting_assignments do |t|
      t.integer :time_shifting_id
      t.integer :department_id
      t.integer :created_by
      t.integer :updated_by
      t.datetime :completed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :department_time_shifting_assignments
  end
end
