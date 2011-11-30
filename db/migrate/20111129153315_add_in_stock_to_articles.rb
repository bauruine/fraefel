class AddInStockToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :in_stock, :string
    add_column :articles, :old_stock, :string
  end

  def self.down
    remove_column :articles, :old_stock
    remove_column :articles, :in_stock
  end
end