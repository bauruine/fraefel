class Address < ActiveRecord::Base
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :referee, :class_name => "Referee", :foreign_key => "referee_id"
  
  has_many :purchase_order_address_assignments, :class_name => "PurchaseOrderAddressAssignment"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :through => :purchase_order_address_assignments
  
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
  
  def self.patch_import(upload_id)
    puts Address.count
    #@baan_import = BaanImport.find(upload_id)
    
    csv_file_path = upload_id
    
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
    ag = Time.now
    csv_todos = {"kat_b" => [21, 22, 23, 24, 25, 26], "kat_a" => [29, 30, 35, 36, 37, 38], "kat_c" => [45, 46, 47, 48, 50, 51]}

    csv_file.each do |row|
      csv_todos.each do |k, v|
        csv_address_code = row[v[0]].to_s.undress
        csv_company_name = row[v[1]].to_s.undress
        csv_street = row[v[2]].to_s.undress
        csv_street_number = row[v[3]].to_s.undress
        csv_postal_code = row[v[4]].to_s.undress
        csv_city = row[v[5]].to_s.undress
        
        csv_category = Category.where(:title => k).first
        address = Address.find_or_create_by_code_and_category_id(:code => csv_address_code, :category_id => csv_category.id, :company_name => csv_company_name, :street => (csv_street + " " + csv_street_number), :postal_code => csv_postal_code, :city => csv_city)
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
    puts Address.count
  end
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    ag = Time.now
    csv_todos = {"kat_b" => [47, 48, 49, 50, 51, 52], "kat_a" => [55, 56, 61, 62, 63, 64], "kat_c" => [71, 72, 73, 74, 75, 76]}
    address_attributes = {}

    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      csv_todos.each do |k, v|
        address_attributes.merge!(:address_code => baan_raw_data.attributes["baan_#{v[0]}"])
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

end
