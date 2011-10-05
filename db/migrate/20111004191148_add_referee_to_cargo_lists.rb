class AddRefereeToCargoLists < ActiveRecord::Migration
  def self.up
    add_column :cargo_lists, :referee, :string
  end

  def self.down
    remove_column :cargo_lists, :referee
  end
end
