class CreateDepartmentUserAssignments < ActiveRecord::Migration
  def self.up
    create_table :department_user_assignments do |t|
      t.integer :user_id
      t.integer :department_id
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :department_user_assignments
  end
end
