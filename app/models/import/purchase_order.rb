class Import::PurchaseOrder < Ohm::Model
  attribute :baan_id
  attribute :mapper_id
  
  unique :baan_id
  
  index :baan_id
  index :mapper_id
  
  def self.destroy_all
    self.all.each do |purchase_order|
      purchase_order.delete
    end
  end
  
  def self.get_mapper_id(attrs)
    begin
      mapper_id = self.find(attrs).first.mapper_id.to_i
    rescue NoMethodError
      return nil
    end
  end
  
  def create_purchase_position(attrs)
    attrs = attrs.merge!(:purchase_order_id => self.id)
    Import::PurchasePosition.create(attrs)
  end
  
  def build_purchase_position(attrs)
    attrs = attrs.merge!(:purchase_order_id => self.id)
    Import::PurchasePosition.new(attrs)
  end
  
  def purchase_positions
    Import::PurchasePosition.find(:purchase_order_id => self.id)
  end
  
end
