class AddBaanIdToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :baan_id, :string
    
    PurchasePosition.all.each do |purchase_position|
      @purchase_order = purchase_position.purchase_order.present? ? purchase_position.purchase_order.baan_id : nil
      purchase_position.update_attribute(:baan_id, "#{@purchase_order}-#{purchase_position.position}")
    end
    
  end

  def self.down
    remove_column :purchase_positions, :baan_id
  end
end