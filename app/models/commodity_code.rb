class CommodityCode < ActiveRecord::Base
  validates_uniqueness_of :code
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    commodity_code_attributes = {}
    
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      commodity_code_attributes.merge!(:code => baan_raw_data.attributes["baan_0"])
      commodity_code_attributes.merge!(:content => baan_raw_data.attributes["baan_1"])
      
      commodity_code = CommodityCode.where(:code => baan_raw_data.baan_0)
      if commodity_code.present? and commodity_code.select("code, content").first.attributes != commodity_code_attributes
        commodity_code.first.update_attributes(commodity_code_attributes)
      else
        CommodityCode.find_or_create_by_code(commodity_code_attributes)
      end
    end
    
  end
  
end
