class AddAggregationalFieldsOnPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :manufacturing_completed, :boolean, :default => false
    add_column :purchase_orders, :warehousing_completed, :boolean, :default => false
    PurchaseOrder.all.each do |p_o|
      m_c_status = p_o.purchase_positions.sum(:production_status) == p_o.purchase_positions.count
      w_c_status = p_o.purchase_positions.sum(:stock_status) == p_o.purchase_positions.count
      p_o.update_attributes(:manufacturing_completed => m_c_status, :warehousing_completed => w_c_status)
    end
  end

  def self.down
    remove_column :purchase_orders, :warehousing_completed
    remove_column :purchase_orders, :manufacturing_completed
  end
end