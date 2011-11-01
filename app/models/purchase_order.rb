class PurchaseOrder < ActiveRecord::Base
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "purchase_order_id"
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
    @baan_import = arg
    PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      customer = Customer.find_by_baan_id(Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip)
      baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      csv_customer = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
      delivery_route = ShippingRoute.find_by_name(Iconv.conv('UTF-8', 'iso-8859-1', row[21]).to_s.chomp.lstrip.rstrip)
    
      purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(:baan_id => baan_id, :customer => customer, :status => "open", :shipping_route => delivery_route)
      if purchase_order.present? && purchase_order.new_record?
        if purchase_order.save
          #puts "New Purchase Order has been created: #{purchase_order.attributes}"
        else
          puts "ERROR-- PurchaseOrder not saved..."
        end
      else
        if (purchase_order.baan_id == baan_id && purchase_order.status == "open" && purchase_order.customer.baan_id != csv_customer)
          purchase_order.update_attributes(:customer => customer)
          puts "Purchase Order #{purchase_order.id} was updated with a different Customer... You should check it manualy!"
        end
      end
    end
    
  end
end
