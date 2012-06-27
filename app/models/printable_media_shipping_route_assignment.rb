class PrintableMediaShippingRouteAssignment < ActiveRecord::Base
  belongs_to :printable_media, :class_name => "PrintableMedia", :foreign_key => "printable_media_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"

end
