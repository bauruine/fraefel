class ShippingRoute < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  
  def self.import(arg)
    @baan_import = arg
    PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      delivery_route = Iconv.conv('UTF-8', 'iso-8859-1', row[21]).to_s.chomp.lstrip.rstrip
    
      shipping_route = ShippingRoute.find_or_initialize_by_name(:name => delivery_route, :active => true)
      if shipping_route.present? && shipping_route.new_record? && shipping_route.name.present?
        shipping_route.save
        puts "New ShippingRoute has been created: #{shipping_route.attributes}"
      end
    end
    
  end
  
end
