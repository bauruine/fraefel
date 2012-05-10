class TimeShifting < ActiveRecord::Base
  attr_accessor :articles
  
  has_many :purchase_position_time_shifting_assignments
  has_many :purchase_positions, :class_name => "PurchasePosition", :through => :purchase_position_time_shifting_assignments
  has_many :comments, :as => :commentable
  
  has_many :shifting_reason_time_shifting_assignments
  has_many :shifting_reasons, :class_name => "ShiftingReason", :through => :shifting_reason_time_shifting_assignments
  
  belongs_to :department, :class_name => "Department", :foreign_key => "department_id"
  
  accepts_nested_attributes_for :purchase_position_time_shifting_assignments
  accepts_nested_attributes_for :shifting_reason_time_shifting_assignments
  accepts_nested_attributes_for :comments, :reject_if => proc { |obj| obj['content'].blank? }
  
  
  
end
