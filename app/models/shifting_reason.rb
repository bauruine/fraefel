class ShiftingReason < ActiveRecord::Base
  has_many :department_shifting_reason_assignments
  has_many :departments, :class_name => "Department", :through => :department_shifting_reason_assignments
  
  has_many :shifting_reason_time_shifting_assignments
  has_many :time_shiftings, :class_name => "TimeShifting", :through => :shifting_reason_time_shifting_assignments
  
end
