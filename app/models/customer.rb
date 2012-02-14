class Customer < ActiveRecord::Base
  validates_presence_of :company
  has_many :shipping_addresses, :class_name => "ShippingAddress", :foreign_key => "customer_id"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :foreign_key => "customer_id"
  has_many :referees, :class_name => "Referee", :foreign_key => "customer_id"
  has_many :addresses, :class_name => "Address", :foreign_key => "customer_id"
  
  accepts_nested_attributes_for :shipping_addresses
  has_paper_trail :on => [:update]
  
  def simplified
    self.company.downcase.delete(' ')
  end
  
  def self.import(arg)
    @baan_import = arg
    PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      company = Iconv.conv('UTF-8', 'iso-8859-1', row[5]).to_s.chomp.lstrip.rstrip
      #baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
      baan_id = row[6].to_s.chomp.lstrip.rstrip
      
      customer = Customer.find_or_initialize_by_baan_id(:baan_id => baan_id, :company => company)
      
      if customer.present? && customer.new_record?
        if customer.save
          #puts "New Customer has been created: #{customer.attributes}"
        else
          puts "ERROR-- Customer not saved..."
        end
      else
        if (customer.baan_id == baan_id && customer.company != company)
          customer.update_attributes(:company => company)
          puts "Customer #{customer.id} was updated with a different Copmany Name... You should check it manualy!"
        end
      end
      
    end
  end
  
end
