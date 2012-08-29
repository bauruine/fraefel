class ChangeColumnTypeOfDeliveryDateOnPurchasePositions < ActiveRecord::Migration
  def up
    change_column :purchase_positions, :delivery_date, :date
  end

  def down
    change_column :purchase_positions, :delivery_date, :datetime
  end
end
