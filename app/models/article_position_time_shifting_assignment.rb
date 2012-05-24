class ArticlePositionTimeShiftingAssignment < ActiveRecord::Base
  belongs_to :article_position, :class_name => "ArticlePosition", :foreign_key => "article_position_id"
  belongs_to :time_shifting, :class_name => "TimeShifting", :foreign_key => "time_shifting_id"
  
  has_many :comments, :as => :commentable
  
  accepts_nested_attributes_for :article_position, :reject_if => proc { |obj| obj['baan_id'].blank? }
  accepts_nested_attributes_for :comments, :reject_if => proc { |obj| obj['content'].blank? }
  
end
