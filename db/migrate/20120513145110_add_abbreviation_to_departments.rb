class AddAbbreviationToDepartments < ActiveRecord::Migration
  def self.up
    add_column :departments, :abbreviation, :string
  end

  def self.down
    remove_column :departments, :abbreviation
  end
end