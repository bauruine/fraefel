class AddAddressToCargoLists < ActiveRecord::Migration
  def self.up
    add_column :cargo_lists, :zip, :integer
    add_column :cargo_lists, :country, :string
    add_column :cargo_lists, :street, :string
    add_column :cargo_lists, :city, :string
  end

  def self.down
    remove_column :cargo_lists, :zip
    remove_column :cargo_lists, :country
    remove_column :cargo_lists, :street
    remove_column :cargo_lists, :city
    
  end
end
