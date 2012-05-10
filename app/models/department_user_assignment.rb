class DepartmentUserAssignment < ActiveRecord::Base
  belongs_to :department, :class_name => "Department", :foreign_key => "department_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
end
