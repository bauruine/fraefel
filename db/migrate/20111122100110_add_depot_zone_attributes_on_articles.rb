class AddDepotZoneAttributesOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :rack_group_number, :string
    add_column :articles, :rack_root_number, :string
    add_column :articles, :rack_part_number, :string
    add_column :articles, :rack_tray_number, :string
    add_column :articles, :rack_box_number, :string
  end

  def self.down
    remove_column :articles, :rack_box_number
    remove_column :articles, :rack_tray_number
    remove_column :articles, :rack_part_number
    remove_column :articles, :rack_root_number
    remove_column :articles, :rack_group_number
  end
end