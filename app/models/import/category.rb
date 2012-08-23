class Import::Category < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  attribute :unique_id
  # Available Types
  # pending list... :P
  attribute :categorizable_type
  
  unique :unique_id
  
  index :baan_id
  index :mapper_id
  index :categorizable_type
  index :unique_id
  
  def self.fill_up
    ::Category.where(:categorizable_type => "purchase_order").each do |category|
      unless self.find(:unique_id => Digest::MD5.hexdigest(%Q(#{category.title}-purchase_order))).present?
        self.create(:baan_id => category.title, :mapper_id => category.id.to_s, :unique_id => Digest::MD5.hexdigest(%Q(#{category.title}-purchase_order)))
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |category|
      category.delete
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
