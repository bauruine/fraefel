class Department < ActiveRecord::Base
  has_many :department_user_assignments
  has_many :users, :class_name => "User", :through => :department_user_assignments
  
  has_many :department_shifting_reason_assignments
  has_many :shifting_reasons, :class_name => "ShiftingReason", :through => :department_shifting_reason_assignments
  
end
