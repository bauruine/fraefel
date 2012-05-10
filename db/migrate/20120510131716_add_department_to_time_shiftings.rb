class AddDepartmentToTimeShiftings < ActiveRecord::Migration
  def self.up
    add_column :time_shiftings, :department_id, :integer
  end

  def self.down
    remove_column :time_shiftings, :department_id
  end
end