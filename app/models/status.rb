class Status < ActiveRecord::Base
  STATUSABLE_ITEMS = ['delivery_rejection']
  has_many :delivery_rejections, :class_name => "DeliveryRejection", :foreign_key => "status_id"
end
