class CommodityCode < ActiveRecord::Base
  has_many :purchase_positions
  
  validates_uniqueness_of :code
  
  after_create :update_import_commodity_code
  
  def self.create_from_raw_data(arg)
    commodity_code_attributes = Hash.new
    
    commodity_code_attributes.merge!(:code => arg.attributes["baan_0"])
    commodity_code_attributes.merge!(:content => arg.attributes["baan_1"])
    
    commodity_code = CommodityCode.find_or_create_by_code(commodity_code_attributes)
  end
  
  protected
  
  def update_import_commodity_code
    import_commodity_code = Import::CommodityCode.find(:baan_id => self.code).first
    unless import_commodity_code.nil?
      import_commodity_code.update(:mapper_id => self.id.to_s)
    end
  end
  
end
