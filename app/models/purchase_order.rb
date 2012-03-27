class PurchaseOrder < ActiveRecord::Base
  has_one :calculation, :as => :calculable, :dependent => :destroy
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :address, :class_name => "Address", :foreign_key => "address_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "purchase_order_id", :dependent => :destroy
  has_many :purchase_order_pallet_assignments
  has_many :pallets, :class_name => "Pallet", :through => :purchase_order_pallet_assignments
  has_many :purchase_order_address_assignments
  has_many :addresses, :class_name => "Address", :through => :purchase_order_address_assignments
  has_many :old_pallets, :class_name => "Pallet", :foreign_key => "purchase_order_id"
  
  scope :ordered_for_delivery, order("purchase_orders.shipping_route_id asc, purchase_orders.customer_id asc, purchase_orders.delivery_date asc, purchase_orders.id asc")
  ##scope :level_1, lambda {|ad_id| includes(:addresses).group("purchase_orders.id").having("count(addresses.id)=1").where("addresses.id = ?", ad_id)}
  ##scope :level_2, lambda {|ad_id| includes(:addresses).group("purchase_orders.id").having("count(addresses.id)=1").where("addresses.id = ?", ad_id)}
  ##scope :level_3, lambda {|ad_id| includes(:addresses).group("purchase_orders.id").having("count(addresses.id)=1").where("addresses.id = ?", ad_id)}
  ##scope :level_3, lambda {|ad_id| includes(:addresses).where("addresses.category_id = ?", 7).where("addresses.id = ?", ad_id)}
  ##search_methods [:level_1, :level_2, :level_3]
  
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
  
  def self.patch_calculation
    self.where("calculations.id is null").includes(:calculation).each do |purchase_order|
      purchase_order.create_calculation unless purchase_order.calculation.present?
      purchase_order.calculation.update_attributes(:total_pallets => purchase_order.pallets.count, :total_purchase_positions => purchase_order.purchase_positions.count)
    end
  end
  
  def self.patch_addresses_local
    self.all.each do |purchase_order|
      @level_1 = purchase_order.addresses.where(:category_id => 5).try(:first).try(:id)
      @level_2 = purchase_order.addresses.where(:category_id => 6).try(:first).try(:id)
      @level_3 = purchase_order.addresses.where(:category_id => 7).try(:first).try(:id)
      purchase_order.update_attributes(:level_1 => @level_1, :level_2 => @level_2, :level_3 => @level_3)
    end
  end
  
  def self.patch_workflow_statuses
    self.all.each do |p_o|
      p_o.update_attributes(:stock_status => p_o.purchase_positions.sum(:stock_status), :production_status => p_o.purchase_positions.sum(:production_status), :workflow_status => "#{p_o.purchase_positions.sum(:production_status)}#{p_o.purchase_positions.sum(:stock_status)}")
    end
  end
  
  def self.patch_import(upload_id)
    csv_file_path = upload_id
    
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
    ag = Time.now
    
    csv_file.each do |row|
      csv_purchase_order = row[0].to_s.undress
      level_1 =  Address.where(:code => row[29].to_s.undress, :category_id => 8).try(:first).try(:id)
      level_2 =  Address.where(:code => row[21].to_s.undress, :category_id => 9).try(:first).try(:id)
      level_3 =  Address.where(:code => row[45].to_s.undress, :category_id => 10).try(:first).try(:id)
      
      purchase_order = PurchaseOrder.where(:baan_id => csv_purchase_order)
      
      if purchase_order.present?
        purchase_order.first.update_attributes(:level_1 => level_1, :level_2 => level_2, :level_3 => level_3)
        purchase_order.first.addresses += Address.where(:id => [level_1, level_2, level_3])
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
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
      csv_warehouse_number = row[22].to_s.undress
      level_1 =  Address.where(:code => row[55].to_s.undress, :category_id => 8).try(:first).try(:id)
      level_2 =  Address.where(:code => row[47].to_s.undress, :category_id => 9).try(:first).try(:id)
      level_3 =  Address.where(:code => row[71].to_s.undress, :category_id => 10).try(:first).try(:id)
    
      purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(:baan_id => baan_id, :customer => customer, :status => "open", :shipping_route => delivery_route, :address => csv_address, :level_1 => level_1, :level_2 => level_2, :level_3 => level_3)
      if purchase_order.present? && purchase_order.new_record?
        purchase_order.stock_status = purchase_order.purchase_positions.sum(:stock_status)
        purchase_order.production_status = purchase_order.purchase_positions.sum(:production_status)
        purchase_order.workflow_status = "#{purchase_order.purchase_positions.sum(:production_status)}#{purchase_order.purchase_positions.sum(:stock_status)}"
        purchase_order.warehouse_number = csv_warehouse_number
        if purchase_order.save
          #puts "New Purchase Order has been created: #{purchase_order.attributes}"
        else
          puts "ERROR-- PurchaseOrder not saved..."
        end
      else
        if (purchase_order.baan_id == baan_id && purchase_order.status == "open")
          purchase_order.update_attributes(:warehouse_number => csv_warehouse_number, :address => csv_address, :level_1 => level_1, :level_2 => level_2, :level_3 => level_3, :stock_status => purchase_order.purchase_positions.sum(:stock_status), :production_status => purchase_order.purchase_positions.sum(:production_status), :workflow_status => "#{purchase_order.purchase_positions.sum(:production_status)}#{purchase_order.purchase_positions.sum(:stock_status)}")
        end
      end
      purchase_order.addresses += Address.where(:id => [level_1, level_2, level_3])
    end
    # Updating manufacturing_warehousing -- temp here.. move somewhere else...
    PurchaseOrder.all.each do |p_o|
      m_c_status = p_o.purchase_positions.sum(:production_status) * (100 / p_o.purchase_positions.count)
      w_c_status = p_o.purchase_positions.sum(:stock_status) * (100 / p_o.purchase_positions.count)
      p_o.update_attributes(:manufacturing_completed => m_c_status, :warehousing_completed => w_c_status)
    end
    
    ab = Time.now
    puts (ab - ag).to_s
  end
end
