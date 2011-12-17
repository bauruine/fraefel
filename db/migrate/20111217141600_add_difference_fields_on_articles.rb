class AddDifferenceFieldsOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :baan_vstk, :string
    add_column :articles, :baan_vstr, :string
    add_column :articles, :baan_cstk, :string
    add_column :articles, :baan_cstr, :string
  end

  def self.down
    remove_column :articles, :baan_cstr
    remove_column :articles, :baan_cstk
    remove_column :articles, :baan_vstr
    remove_column :articles, :baan_vstk
  end
end