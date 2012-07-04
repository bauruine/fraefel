class RemoveConsigneeFullFromPurchasePositions < ActiveRecord::Migration
  def self.up
    PurchasePosition.where("purchase_orders.level_3 IS NOT NULL").where("purchase_orders.id IS NOT NULL").includes(:purchase_order).each do |purchase_position|
      @delivery_address = Address.find(purchase_position.purchase_order.level_3)
      @delivery_country = purchase_position.consignee_full.split(", ").last.split("-").first
      @delivery_address.update_attribute("country", @delivery_country)
    end
    remove_column :purchase_positions, :consignee_full
  end

  def self.down
  end
end
