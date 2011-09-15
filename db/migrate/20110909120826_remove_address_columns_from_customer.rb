class RemoveAddressColumnsFromCustomer < ActiveRecord::Migration
  def self.up
    remove_column :customers, :street
    remove_column :customers, :city
    remove_column :customers, :zip
    remove_column :customers, :country
  end

  def self.down
    add_column :customers, :street, :string
    add_column :customers, :city, :string
    add_column :customers, :zip, :integer
    add_column :customers, :country, :string
    
  end
end
