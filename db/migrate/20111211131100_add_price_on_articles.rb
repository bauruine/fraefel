class AddPriceOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :price, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :articles, :price
  end
end