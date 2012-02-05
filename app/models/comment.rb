class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user, :class_name => "User", :foreign_key => "created_by"
end
