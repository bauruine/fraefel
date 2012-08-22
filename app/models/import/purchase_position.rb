class Import::PurchasePosition < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  attribute :purchase_order_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  index :purchase_order_id
  
  def self.fill_up
    ::PurchasePosition.where("purchase_positions.baan_id IS NOT NULL").each do |purchase_position|
      unless self.find(:baan_id => purchase_position.baan_id).present?
        self.create(:baan_id => purchase_position.baan_id, :mapper_id => purchase_position.id.to_s, :purchase_order_id => purchase_position.purchase_order_id.to_s)
      end
    end
  end
  
  def self.destroy_all
    self.all.each do |purchase_position|
      purchase_position.delete
    end
  end
  
  def purchase_order=(purchase_order)
    self.purchase_order_id = purchase_order.id
  end

  def purchase_order
    Import::PurchaseOrder[self.purchase_order_id]
  end
end
