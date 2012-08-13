class AddLevel3ToCargoLists < ActiveRecord::Migration
  def change
    add_column :cargo_lists, :level_3, :integer
  end
end
