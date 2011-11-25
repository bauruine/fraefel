class ChangeColumnDepotType < ActiveRecord::Migration
  def self.up
    rename_column :depots, :type, :depot_type_id
  end

  def self.down
    rename_column :depots, :depot_type_id, :type
  end
end