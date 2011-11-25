class ChangeColumnDepotCodeOnDepots < ActiveRecord::Migration
  def self.up
    rename_column :articles, :depot_code, :depot_id
  end

  def self.down
    rename_column :articles, :depot_id, :depot_code
  end
end