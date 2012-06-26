class ShippingRoute < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  has_many :purchase_orders
  
  has_many :printable_media_shipping_route_assignments
  has_many :printable_media, :through => :printable_media_shipping_route_assignments
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    shipping_route_attributes = {}
    
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      shipping_route_attributes.merge!(:name => baan_raw_data.attributes["baan_21"])
      shipping_route_attributes.merge!(:active => true)
      
      ShippingRoute.find_or_create_by_name(shipping_route_attributes)
    end
    
  end
  
end
