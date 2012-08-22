class Import::Customer < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.fill_up
    ::Customer.all.each do |customer|
      unless self.find(:baan_id => customer.baan_id).present?
        self.create(:baan_id => customer.baan_id, :mapper_id => customer.id.to_s)
      end
    end
  end
  
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
