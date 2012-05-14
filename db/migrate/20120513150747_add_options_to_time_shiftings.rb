class AddOptionsToTimeShiftings < ActiveRecord::Migration
  def self.up
    add_column :time_shiftings, :customer_was_informed, :boolean
    add_column :time_shiftings, :baan_was_updated, :boolean
    add_column :time_shiftings, :we_date, :date
    add_column :time_shiftings, :lt_date, :date
    add_column :time_shiftings, :change_we_date, :boolean
    add_column :time_shiftings, :change_lt_date, :boolean
    add_column :time_shiftings, :closed, :boolean
  end

  def self.down
    remove_column :time_shiftings, :closed
    remove_column :time_shiftings, :change_lt_date
    remove_column :time_shiftings, :change_we_date
    remove_column :time_shiftings, :lt_date
    remove_column :time_shiftings, :we_date
    remove_column :time_shiftings, :baan_was_updated
    remove_column :time_shiftings, :customer_is_informed
  end
end