class AddRackRootPartNumberOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :rack_root_part_number, :string
  end

  def self.down
    remove_column :articles, :rack_root_part_number
  end
end