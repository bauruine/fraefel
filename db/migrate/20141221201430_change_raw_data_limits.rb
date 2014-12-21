class ChangeRawDataLimits < ActiveRecord::Migration
  def up
    (0..84).each do |i|
      change_column :baan_raw_data, "baan_#{i}", :string, :limit => 50
    end
  end

  def down
    (0..84).each do |i|
      change_column :baan_raw_data, "baan_#{i}", :string, :limit => 255
    end
  end
end
