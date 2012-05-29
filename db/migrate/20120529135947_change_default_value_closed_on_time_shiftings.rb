class ChangeDefaultValueClosedOnTimeShiftings < ActiveRecord::Migration
  def self.up
    change_column_default :time_shiftings, :closed, false
  end

  def self.down
    change_column_default :time_shiftings, :closed, nil
  end
end