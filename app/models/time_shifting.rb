# encoding: utf-8
class TimeShifting < ActiveRecord::Base
  attr_accessor :articles
  
  has_many :purchase_position_time_shifting_assignments, :dependent => :destroy
  has_many :purchase_positions, :class_name => "PurchasePosition", :through => :purchase_position_time_shifting_assignments
  has_many :comments, :as => :commentable
  
  has_many :shifting_reason_time_shifting_assignments, :dependent => :destroy
  has_many :shifting_reasons, :class_name => "ShiftingReason", :through => :shifting_reason_time_shifting_assignments
  
  has_many :article_position_time_shifting_assignments, :dependent => :destroy
  has_many :article_positions, :class_name => "ArticlePosition", :through => :article_position_time_shifting_assignments
  
  has_many :department_time_shifting_assignments, :dependent => :destroy
  has_many :departments, :class_name => "Department", :through => :department_time_shifting_assignments
  
  belongs_to :department, :class_name => "Department", :foreign_key => "department_id"
  
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id", :primary_key => "baan_id"
  
  accepts_nested_attributes_for :purchase_position_time_shifting_assignments
  accepts_nested_attributes_for :shifting_reason_time_shifting_assignments
  accepts_nested_attributes_for :comments, :reject_if => proc { |obj| obj['content'].blank? }
  accepts_nested_attributes_for :article_positions
  accepts_nested_attributes_for :article_position_time_shifting_assignments
  accepts_nested_attributes_for :department_time_shifting_assignments, :reject_if => proc { |obj| obj['department_id'].blank? }
  accepts_nested_attributes_for :purchase_order
  
  validates_presence_of :department_id, :on => :create, :message => "muss ausgewählt werden"
  validates_presence_of :shifting_reasons, :on => :create, :message => "muss ausgewählt werden"
  #validates_presence_of :purchase_positions
  
end
