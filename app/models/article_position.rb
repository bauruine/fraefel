class ArticlePosition < ActiveRecord::Base
  has_many :article_position_time_shifting_assignments
  has_many :time_shiftings, :class_name => "TimeShifting", :through => :article_position_time_shifting_assignments
  
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
end
