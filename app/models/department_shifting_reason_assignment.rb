class DepartmentShiftingReasonAssignment < ActiveRecord::Base
  belongs_to :department, :class_name => "Department", :foreign_key => "department_id"
  belongs_to :shifting_reason, :class_name => "ShiftingReason", :foreign_key => "shifting_reason_id"
end
