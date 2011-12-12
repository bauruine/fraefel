class AddArticleGroupIdToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :article_group_id, :integer
  end

  def self.down
    remove_column :articles, :article_group_id
  end
end