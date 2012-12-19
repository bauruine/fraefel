class AddStocktakingIdToArticleGroups < ActiveRecord::Migration
  def change
    add_column :article_groups, :stocktaking_id, :string
  end
end
