class Converter::PurchasePosition < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  attribute :delivery_date
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.fill_up
    ::PurchasePosition.where("purchase_positions.baan_id IS NOT NULL").each do |purchase_position|
      unless self.find(:baan_id => purchase_position.baan_id).present?
        self.create(:baan_id => purchase_position.baan_id, :mapper_id => purchase_position.id.to_s, :delivery_date => purchase_position.delivery_date.to_date.to_s)
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |purchase_position|
      purchase_position.delete
    end
  end

end
