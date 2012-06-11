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
  validates_presence_of :lt_date, :on => :update, :message => "muss gesetzt werden", :if => "closed"
  #validates_presence_of :purchase_positions
  
  def self.clean_up
    where(:closed => false).each do |ts|
      @considered = ts.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).includes(:purchase_position_time_shifting_assignments)
      @production_completed = ts.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).where("purchase_positions.production_status = 1").includes(:purchase_position_time_shifting_assignments)
      if @considered.count == @production_completed.count
        ts.update_attribute("closed", true)
        ts.comments.create(:content => "Closed by system", :created_by => User.first.id)
        @considered.update_all(:priority_level => 2)
        if ts.lt_date.present?
          @considered.each do |pu_po|
            pu_po.delivery_dates.last.try(:date_of_delivery) != pu_po.delivery_date.to_date ? pu_po.delivery_dates.create(:date_of_delivery => ts.lt_date) : nil
            pu_po.update_attribute(:delivery_date, ts.lt_date)
          end
          if ts.purchase_order.present?
            ts.purchase_order.update_attribute("delivery_date", ts.lt_date)
          end
        end
      end
    end
  end
  
end
