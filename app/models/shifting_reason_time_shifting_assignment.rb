class ShiftingReasonTimeShiftingAssignment < ActiveRecord::Base
  belongs_to :shifting_reason, :class_name => "ShiftingReason", :foreign_key => "shifting_reason_id"
  belongs_to :time_shifting, :class_name => "TimeShifting", :foreign_key => "time_shifting_id"
  
end
