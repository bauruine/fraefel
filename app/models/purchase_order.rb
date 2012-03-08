class PurchaseOrder < ActiveRecord::Base
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :address, :class_name => "Address", :foreign_key => "address_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "purchase_order_id", :dependent => :destroy
  has_many :purchase_order_pallet_assignments
  has_many :pallets, :class_name => "Pallet", :through => :purchase_order_pallet_assignments
  has_many :old_pallets, :class_name => "Pallet", :foreign_key => "purchase_order_id"
  
  def amount
    amount = 0
    purchase_positions.each do |purchase_position|
      amount = amount + purchase_position.amount
    end
    return amount
  end
  
  def weight_total
    weight_total = 0
    purchase_positions.each do |purchase_position|
      weight_total = weight_total + purchase_position.weight_total
    end
    return weight_total
  end
  
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    PaperTrail.whodunnit = 'System'
    
    csv_file_path = @baan_import.baan_upload.path
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
    
    ag = Time.now
    
    csv_file.each do |row|
      csv_address = Address.find_by_code(row[71].to_s.undress)
      customer = Customer.find_by_baan_id(row[6].to_s.undress)
      baan_id = row[2].to_s.undress
      csv_customer = row[6].to_s.undress
      delivery_route = ShippingRoute.find_by_name(row[21].to_s.undress)
    
      purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(:baan_id => baan_id, :customer => customer, :status => "open", :shipping_route => delivery_route, :address => csv_address)
      if purchase_order.present? && purchase_order.new_record?
        if purchase_order.save
          #puts "New Purchase Order has been created: #{purchase_order.attributes}"
        else
          puts "ERROR-- PurchaseOrder not saved..."
        end
      else
        if (purchase_order.baan_id == baan_id && purchase_order.status == "open" && purchase_order.try(:address).try(:code) != row[71].to_s.undress)
          purchase_order.update_attributes(:address => csv_address)
        end
      end
    end
    
    ab = Time.now
    puts (ab - ag).to_s
  end
end
