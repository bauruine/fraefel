class Address < ActiveRecord::Base
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :referee, :class_name => "Referee", :foreign_key => "referee_id"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :foreign_key => "address_id"
  
  def location_full
    "#{self.postal_code} #{self.city}"
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

  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    csv_file_path = @baan_import.baan_upload.path
    
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
    ag = Time.now
    csv_todos = [71]#41, 65

    csv_file.each do |row|
      csv_todos.each do |t_row|
        csv_address_code = row[t_row].to_s.undress
        csv_company_name = row[t_row + 1].to_s.undress
        csv_street = row[t_row + 2].to_s.undress
        csv_street_number = row[t_row + 3].to_s.undress
        csv_postal_code = row[t_row + 4].to_s.undress
        csv_city = row[t_row + 5].to_s.undress

        address = Address.find_or_create_by_code(:code => csv_address_code, :company_name => csv_company_name, :street => (csv_street + " " + csv_street_number), :postal_code => csv_postal_code, :city => csv_city)
        unless address.new_record?
          address.update_attributes(:company_name => csv_company_name, :street => (csv_street + " " + csv_street_number), :postal_code => csv_postal_code, :city => csv_city)
        end
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end

end
