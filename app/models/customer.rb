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
    @baan_import = BaanImport.find(arg)
    PaperTrail.whodunnit = 'System'
    
    customer_attributes = {}
    
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      customer_attributes.merge!(:company => baan_raw_data.attributes["baan_5"])
      customer_attributes.merge!(:baan_id => baan_raw_data.attributes["baan_6"])
      
      customer = Customer.find_or_create_by_baan_id(customer_attributes)
    end
  end
  
end
