class AddDefaultValuesToCalculations < ActiveRecord::Migration
  def self.up
    change_column_default :calculations, :total_pallets, 0
    change_column_default :calculations, :total_purchase_positions, 0
  end

  def self.down
    change_column_default :calculations, :total_purchase_positions, nil
    change_column_default :calculations, :total_pallets, nil
  end
end