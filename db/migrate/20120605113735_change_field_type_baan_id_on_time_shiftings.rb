class ChangeFieldTypeBaanIdOnTimeShiftings < ActiveRecord::Migration
  def self.up
    change_column :time_shiftings, :purchase_order_id, :string
  end

  def self.down
    change_column :time_shiftings, :purchase_order_id, :integer
  end
end