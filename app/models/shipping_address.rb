class ShippingAddress < ActiveRecord::Base
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    PaperTrail.whodunnit = 'System'
    
    shipping_address_attributes = {}
    
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      shipping_address_attributes.merge!(:street => baan_raw_data.attributes["baan_7"] + " " + baan_raw_data.attributes["baan_8"])
      shipping_address_attributes.merge!(:country => baan_raw_data.attributes["baan_9"])
      shipping_address_attributes.merge!(:zip => baan_raw_data.attributes["baan_10"])
      shipping_address_attributes.merge!(:city => baan_raw_data.attributes["baan_11"])
      
      customer = Customer.where(:baan_id => baan_raw_data.baan_6)
      
      if customer.present?
        shipping_addresses = customer.first.shipping_addresses
        if shipping_addresses.present? and shipping_addresses.select("street, country, zip, city").first.attributes != shipping_address_attributes
          shipping_addresses.first.update_attributes(shipping_address_attributes)
        else
          customer.first.shipping_addresses.create(shipping_address_attributes)
        end
      end
      
    end
  end
  
end
