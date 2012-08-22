class Import::ZipLocation < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.fill_up
    ::ZipLocation.all.each do |zip_location|
      unless self.find(:baan_id => zip_location.title).present?
        self.create(:baan_id => zip_location.title, :mapper_id => zip_location.id.to_s)
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |zip_location|
      zip_location.delete
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
