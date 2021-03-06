class Import::ShippingRoute < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.fill_up
    ::ShippingRoute.all.each do |shipping_route|
      unless self.find(:baan_id => shipping_route.name).present?
        self.create(:baan_id => shipping_route.name, :mapper_id => shipping_route.id.to_s)
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |shipping_route|
      shipping_route.delete
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
