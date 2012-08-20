class Import::Customer < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.destroy_all
    self.all.each do |customer|
      customer.delete
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
