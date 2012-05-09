class TimeShifting < ActiveRecord::Base
  attr_accessor :reasons, :articles, :next_department, :comment
  
  has_many :purchase_position_time_shifting_assignments
  has_many :purchase_positions, :class_name => "PurchasePosition", :through => :purchase_position_time_shifting_assignments
  has_many :comments, :as => :commentable
  
  accepts_nested_attributes_for :purchase_position_time_shifting_assignments
  accepts_nested_attributes_for :comments, :reject_if => proc { |obj| obj['content'].blank? }
  
  
  
end
