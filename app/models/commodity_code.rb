class CommodityCode < ActiveRecord::Base
  validates_uniqueness_of :code
  
  def self.import(arg)
    @baan_import = arg
    PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      code = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      content = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      
      if CommodityCode.find_by_code(code)
        commodity_code = CommodityCode.find_by_code(code)
        
        csv_array = [code, content]
        code_array = [commodity_code.code, commodity_code.content]
      
        if csv_array != code_array
          commodity_code.update_attributes(:code => code, :content => content)
        end
      
      else
        CommodityCode.find_or_create_by_code(:code => code, :content => content)
      end
    end
    
  end
  
end
