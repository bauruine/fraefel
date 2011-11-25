class Depot < ActiveRecord::Base
  belongs_to :depot_type, :class_name => "DepotType", :foreign_key => "depot_type_id"
  has_many :articles, :class_name => "Article", :foreign_key => "depot_id"
  
  def self.import(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    depot_type = DepotType.find_or_create_by_title(:title => "Einkaufslager")
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      code = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      description = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      type = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      address_code = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip
      phone_number = Iconv.conv('UTF-8', 'iso-8859-1', row[9]).to_s.chomp.lstrip.rstrip
      fax_number = Iconv.conv('UTF-8', 'iso-8859-1', row[10]).to_s.chomp.lstrip.rstrip
      web_address = Iconv.conv('UTF-8', 'iso-8859-1', row[11]).to_s.chomp.lstrip.rstrip
      
      
      depot = Depot.find_or_initialize_by_code(:code => code)
      if depot.present? && depot.new_record?
        depot.code = code
        depot.description = description
        depot.depot_type = depot_type
        depot.address_code = address_code
        depot.phone_number = phone_number
        depot.fax_number = fax_number
        depot.web_address = web_address
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
