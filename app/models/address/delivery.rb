class Address::Delivery < Address
  default_scope where(:category_id => 10)
  has_many :purchase_orders, :foreign_key => :level_3, :select => "purchase_orders.id, purchase_orders.baan_id, purchase_orders.level_3"

end
