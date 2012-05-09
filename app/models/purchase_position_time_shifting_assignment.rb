class PurchasePositionTimeShiftingAssignment < ActiveRecord::Base
  belongs_to :purchase_position, :class_name => "PurchasePosition", :foreign_key => "purchase_position_id"
  belongs_to :time_shifting, :class_name => "TimeShifting", :foreign_key => "time_shifting_id"
  
end
