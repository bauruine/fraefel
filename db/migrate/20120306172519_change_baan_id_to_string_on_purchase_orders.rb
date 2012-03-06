class ChangeBaanIdToStringOnPurchaseOrders < ActiveRecord::Migration
  def self.up
    change_column :purchase_orders, :baan_id, :string
  end

  def self.down
    change_column :purchase_orders, :baan_id, :integer
  end
end