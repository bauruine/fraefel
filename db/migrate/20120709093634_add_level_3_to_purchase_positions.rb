class AddLevel3ToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :level_3, :integer
    PurchasePosition.all.each do |purchase_position|
      @purchase_order = purchase_position.purchase_order
      if @purchase_order.present?
        purchase_position.update_attribute("level_3", @purchase_order.level_3)
      end
    end
  end

  def self.down
    remove_column :purchase_positions, :level_3
  end
end