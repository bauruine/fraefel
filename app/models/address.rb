class Address < ActiveRecord::Base
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :referee, :class_name => "Referee", :foreign_key => "referee_id"
  belongs_to :delivery_rejection, :class_name => "DeliveryRejection", :foreign_key => "delivery_rejection_id"
  
  has_many :purchase_order_address_assignments, :class_name => "PurchaseOrderAddressAssignment"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :through => :purchase_order_address_assignments
  
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "level_3"
  has_many :pallets, :class_name => "Pallet", :foreign_key => "level_3"
  
  after_create :update_import_address
  
  def consignee_full
    "#{self.company_name}, #{self.street}, #{self.country}-#{self.postal_code} #{self.city}"
  end
  
  def location_full
    "#{self.postal_code} #{self.city}"
  end
  
  def location_for_select
    "#{self.company_name} - #{self.street} - #{self.postal_code} #{self.city}"
  end
  
  def location_all_attributes
    if self.category.present?
      "#{self.category.title}: #{self.street}, #{self.postal_code} #{self.city}"
    else
      "#{self.street}, #{self.postal_code} #{self.city}"
    end
  end
  
  def valid_for_printing
    (self.postal_code.present? && self.city.present? && self.city.present?) ? true : false
  end
  
  def self.patch_import(arg)
    #@baan_import = BaanImport.find(arg)
    csv_file_path = arg
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    ag = Time.now
    csv_todos = {"kat_b" => [21, 22, 23, 24, 25, 26], "kat_a" => [29, 30, 35, 36, 37, 38], "kat_c" => [45, 46, 47, 48, 49, 50]}
    categories = {"kat_b" => Category.where(:title => "kat_b").first.id, "kat_a" => Category.where(:title => "kat_a").first.id, "kat_c" => Category.where(:title => "kat_c").first.id}
    address_level_mapper = {8 => "level_1", 9 => "level_2", 10 => "level_3"}
    address_attributes = {}
    
    csv_file.each do |row|
      csv_todos.each do |k, v|
      
        purchase_order = PurchaseOrder.where(:baan_id => row[2].to_s).first
        if purchase_order.present? and (purchase_order.level_1.nil? or purchase_order.level_2.nil? or purchase_order.level_3.nil?)
          address_attributes.merge!(:country => row["49".to_i])
          address_attributes.merge!(:code => row["#{v[0]}".to_i])
          address_attributes.merge!(:company_name => row["#{v[1]}".to_i])
          address_attributes.merge!(:street => row["#{v[2]}".to_i] + " " + row["#{v[3]}".to_i])
          address_attributes.merge!(:postal_code => row["#{v[4]}".to_i])
          address_attributes.merge!(:city => row["#{v[5]}".to_i])
          address_attributes.merge!(:category_id => categories[k])
          
          address = Address.find_or_create_by_code_and_category_id(address_attributes)
          purchase_order.update_attributes(address_level_mapper[address.category_id] => address.id)
          purchase_order.addresses += [address]
        end
        
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end
  
  def self.patch_import_with_raw_data
    
    ag = Time.now
    csv_todos = {"kat_b" => [47, 48, 49, 50, 51, 52], "kat_a" => [55, 56, 61, 62, 63, 64], "kat_c" => [71, 72, 73, 74, 75, 76]}
    address_attributes = {}
    categories = {"kat_b" => Category.where(:title => "kat_b").first.id, "kat_a" => Category.where(:title => "kat_a").first.id, "kat_c" => Category.where(:title => "kat_c").first.id}
    address_level_mapper = {8 => "level_1", 9 => "level_2", 10 => "level_3"}
    
    purchase_orders = PurchaseOrder.where("level_3 IS NULL OR level_2 IS NULL OR level_1 IS NULL")
    purchase_order_baan_ids = purchase_orders.collect(&:baan_id)

    @baan_raw_data = BaanRawData.where("baan_71 IS NOT NULL").where("baan_2" => purchase_order_baan_ids)
    
    if @baan_raw_data.present?
      @baan_raw_data.each do |baan_raw_data|
        csv_todos.each do |k, v|
        
          purchase_order = PurchaseOrder.where(:baan_id => baan_raw_data.attributes["baan_2"]).first
          
          address_attributes.merge!(:country => baan_raw_data.attributes["baan_9"])
          address_attributes.merge!(:code => baan_raw_data.attributes["baan_#{v[0]}"])
          address_attributes.merge!(:company_name => baan_raw_data.attributes["baan_#{v[1]}"])
          address_attributes.merge!(:street => baan_raw_data.attributes["baan_#{v[2]}"] + " " + baan_raw_data.attributes["baan_#{v[3]}"])
          address_attributes.merge!(:postal_code => baan_raw_data.attributes["baan_#{v[4]}"])
          address_attributes.merge!(:city => baan_raw_data.attributes["baan_#{v[5]}"])
          address_attributes.merge!(:category_id => categories[k])
          
          address = Address.find_or_create_by_code_and_category_id(address_attributes)
          purchase_order.update_attributes(address_level_mapper[address.category_id] => address.id)
          purchase_order.addresses += [address]
        end
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    ag = Time.now
    csv_todos = {"kat_b" => [47, 48, 49, 50, 51, 52], "kat_a" => [55, 56, 61, 62, 63, 64], "kat_c" => [71, 72, 73, 74, 75, 76]}
    address_attributes = {}

    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      csv_todos.each do |k, v|
        address_attributes.merge!(:country => baan_raw_data.attributes["baan_9"])
        address_attributes.merge!(:code => baan_raw_data.attributes["baan_#{v[0]}"])
        address_attributes.merge!(:company_name => baan_raw_data.attributes["baan_#{v[1]}"])
        address_attributes.merge!(:street => baan_raw_data.attributes["baan_#{v[2]}"] + " " + baan_raw_data.attributes["baan_#{v[3]}"])
        address_attributes.merge!(:postal_code => baan_raw_data.attributes["baan_#{v[4]}"])
        address_attributes.merge!(:city => baan_raw_data.attributes["baan_#{v[5]}"])
        address_attributes.merge!(:category_id => Category.where(:title => k).first.id)
        
        address = Address.find_or_create_by_code_and_category_id(address_attributes)
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end
  
  def self.create_from_raw_data(arg)
    address_categories = {"kat_b" => [9, 47, 48, 49, 50, 51, 52], "kat_a" => [9, 55, 56, 61, 62, 63, 64], "kat_c" => [9, 71, 72, 73, 74, 75, 76]}
    categories = {"kat_b" => Category.where(:title => "kat_b").first.id, "kat_a" => Category.where(:title => "kat_a").first.id, "kat_c" => Category.where(:title => "kat_c").first.id}

    address_attributes = Hash.new
    
    address_categories.each do |k, v|
      address_attributes.clear
      address_attributes.merge!(:country => arg.attributes["baan_#{v[0]}"])
      address_attributes.merge!(:code => arg.attributes["baan_#{v[1]}"])
      address_attributes.merge!(:company_name => arg.attributes["baan_#{v[2]}"])
      address_attributes.merge!(:street => arg.attributes["baan_#{v[3]}"] + " " + arg.attributes["baan_#{v[4]}"])
      address_attributes.merge!(:postal_code => arg.attributes["baan_#{v[5]}"])
      address_attributes.merge!(:city => arg.attributes["baan_#{v[6]}"])
      address_attributes.merge!(:category_id => categories[k])

      address = Address.find_or_create_by_code_and_category_id(address_attributes)
    end
  end
  
  protected
  
  def update_import_address
    import_address = Import::Address.find(:baan_id => self.code, :category_id => self.category_id.to_s).first
    unless import_address.nil?
      import_address.update(:mapper_id => self.id.to_s)
    end
  end
  
end
