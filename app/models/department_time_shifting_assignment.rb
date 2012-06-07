class DepartmentTimeShiftingAssignment < ActiveRecord::Base
  belongs_to :time_shifting, :class_name => "TimeShifting", :foreign_key => "time_shifting_id"
  belongs_to :department, :class_name => "Department", :foreign_key => "department_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
end
