class AddAdditionalAddressToBaanRawData < ActiveRecord::Migration
  def change
    add_column :baan_raw_data, :baan_85, :string, :limit => 50
    add_column :baan_raw_data, :baan_86, :string, :limit => 50
    add_column :baan_raw_data, :baan_87, :string, :limit => 50
  end
end
