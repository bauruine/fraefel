class Category < ActiveRecord::Base
  has_many :customers, :class_name => "Customer", :foreign_key => "category_id"
  has_many :addresses, :class_name => "Address", :foreign_key => "category_id"
  
  CATEGORIZABLE_ITEMS = ['delivery_rejection', 'customer', 'address', 'purchase_order']
end
