class AddRawDataFieldsFrom82To84OnBaanRawData < ActiveRecord::Migration
  def self.up
    add_column :baan_raw_data, :baan_82, :string
    add_column :baan_raw_data, :baan_83, :string
    add_column :baan_raw_data, :baan_84, :string
  end

  def self.down
    remove_column :baan_raw_data, :baan_84
    remove_column :baan_raw_data, :baan_83
    remove_column :baan_raw_data, :baan_82
  end
end