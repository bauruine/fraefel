class AddTotalAmountToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :total_amount, :decimal, :precision => 12, :scale => 2
    PurchasePosition.all.each do |purchase_position|
      cal_total = purchase_position.amount * purchase_position.quantity
      purchase_position.update_attributes(:total_amount => cal_total)
    end
  end

  def self.down
    add_column :purchase_positions, :total_amount
  end
end
