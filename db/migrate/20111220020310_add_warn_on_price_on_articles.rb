class AddWarnOnPriceOnArticles < ActiveRecord::Migration
  def self.up
    add_column :article_groups, :warn_on_price, :string
  end

  def self.down
    remove_column :article_groups, :warn_on_price
  end
end