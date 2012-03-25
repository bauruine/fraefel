class AddAggregationalFieldsOnPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :manufacturing_completed, :float, :default => 0
    add_column :purchase_orders, :warehousing_completed, :float, :default => 0
    PurchaseOrder.all.each do |p_o|
      m_c_status = p_o.purchase_positions.sum(:production_status) * (100 / p_o.purchase_positions.count)
      w_c_status = p_o.purchase_positions.sum(:stock_status) * (100 / p_o.purchase_positions.count)
      p_o.update_attributes(:manufacturing_completed => m_c_status, :warehousing_completed => w_c_status)
    end
  end

  def self.down
    remove_column :purchase_orders, :warehousing_completed
    remove_column :purchase_orders, :manufacturing_completed
  end
end