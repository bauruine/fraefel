class Depot < ActiveRecord::Base
  belongs_to :depot_type, :class_name => "DepotType", :foreign_key => "depot_type_id"
  has_many :articles, :class_name => "Article", :foreign_key => "depot_id"
  
  def self.import(arg)
    depot_type = DepotType.find_or_create_by_title(:title => "Einkaufslager")
    @baan_import = BaanImport.where(:id => arg)
    
    csv_file_path = @baan_import.first.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    
    csv_file.each do |row|
      
      code = row[0].to_s.undress
      description = row[1].to_s.undress
      type = row[2].to_s.undress
      address_code = row[4].to_s.undress
      phone_number = row[9].to_s.undress
      fax_number = row[10].to_s.undress
      web_address = row[11].to_s.undress
      
      
      depot = Depot.find_or_initialize_by_code_and_stocktaking_id(:code => code, :stocktaking_id => "dez-2013")
      if depot.present? && depot.new_record?
        depot.code = code
        depot.description = description
        depot.depot_type = depot_type
        depot.address_code = address_code
        depot.phone_number = phone_number
        depot.fax_number = fax_number
        depot.web_address = web_address
        depot.stocktaking_id = "dez-2013"
        depot.save
      else
        depot.update_attributes(:code => code,
                                :description => description,
                                :depot_type => depot_type,
                                :address_code => address_code,
                                :phone_number => phone_number,
                                :fax_number => fax_number,
                                :web_address => web_address)
      end
    end
  end
  
end
