class Import::CommodityCode < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.fill_up
    ::CommodityCode.all.each do |commodity_code|
      unless self.find(:baan_id => commodity_code.code).present?
        self.create(:baan_id => commodity_code.code, :mapper_id => commodity_code.id.to_s)
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |commodity_code|
      commodity_code.delete
    end
  end
  
  def self.get_mapper_id(attrs)
    begin
      mapper_id = self.find(attrs).first.mapper_id.to_i
    rescue NoMethodError
      return nil
    end
  end

end
