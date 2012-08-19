class Import::PurchasePosition < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  attribute :purchase_order_id
  index :purchase_order_id
  
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
