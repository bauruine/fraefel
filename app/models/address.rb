class Address < ActiveRecord::Base
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :referee, :class_name => "Referee", :foreign_key => "referee_id"
  
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

  def self.import(arg = BaanImport.last.id)
    @baan_import = BaanImport.find(arg)
    
    csv_file_path = @baan_import.baan_upload.path
    
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row, :encoding => "iso-8859-1:utf-8"})
    ag = Time.now
    csv_todos = [41, 65]

    csv_file.each do |row|
      csv_todos.each do |t_row|
        csv_address_code = row[t_row].to_s.chomp.lstrip.rstrip
        #unless Address.where(:code => csv_address_code).present?
          csv_street = row[t_row + 2].to_s.chomp.lstrip.rstrip
          csv_street_number = row[t_row + 3].to_s.chomp.lstrip.rstrip
          csv_postal_code = row[t_row + 4].to_s.chomp.lstrip.rstrip
          csv_city = row[t_row + 5].to_s.chomp.lstrip.rstrip

          Address.find_or_create_by_code(:code => csv_address_code, :street => (csv_street + " " + csv_street_number), :postal_code => csv_postal_code, :city => csv_city)
        #end
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end

end
