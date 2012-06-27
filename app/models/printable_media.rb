class PrintableMedia < ActiveRecord::Base
  has_many :printable_media_shipping_route_assignments
  has_many :shipping_routes, :through => :printable_media_shipping_route_assignments
  
end
