class ShippingAddress < ActiveRecord::Base
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  
  def self.import(arg)
    @baan_import = arg
    PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      street = Iconv.conv('UTF-8', 'iso-8859-1', row[7]).to_s.chomp.lstrip.rstrip + " " + Iconv.conv('UTF-8', 'iso-8859-1', row[8]).to_s.chomp.lstrip.rstrip
      zip = row[10]
      city = Iconv.conv('UTF-8', 'iso-8859-1', row[11]).to_s.chomp.lstrip.rstrip
      country = Iconv.conv('UTF-8', 'iso-8859-1', row[9]).to_s.chomp.lstrip.rstrip
      baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
      if Customer.find_by_baan_id(baan_id) && Customer.find_by_baan_id(baan_id).shipping_addresses.first.present?
        customer = Customer.find_by_baan_id(baan_id)
        address = customer.shipping_addresses.first
        
        csv_array = [street, zip, city, country]
        customer_array = [address.street, address.zip, address.city, address.country]
      
        if csv_array != customer_array
          address.update_attributes(:street => street, :zip => zip, :city => city, :country => country)
        end
      
      else
        if Customer.find_by_baan_id(baan_id).present?
          Customer.find_by_baan_id(baan_id).shipping_addresses.build(:street => street, :zip => zip, :city => city, :country => country).save
        else
          # Should write in LOG
        end
      end
    end
      
  end
  
end
