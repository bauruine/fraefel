class Import::Address < Ohm::Model

  attribute :baan_id
  attribute :mapper_id
  attribute :unique_id
  # Available Categories
  # cat_a = 8, cat_b = 9, :cat_c = 10
  attribute :category_id
  
  unique :unique_id
  
  index :baan_id
  index :mapper_id
  index :category_id
  index :unique_id
  
  def self.fill_up
    ::Address.where("addresses.category_id" => [8, 9, 10]).each do |address|
      unless self.find(:unique_id => Digest::MD5.hexdigest("#{address.code}-#{address.category_id}")).present?
        self.create(:category_id => address.category_id.to_s, :baan_id => address.code, :mapper_id => address.id.to_s, :unique_id => Digest::MD5.hexdigest("#{address.code}-#{address.category_id}"))
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |address|
      address.delete
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
