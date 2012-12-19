class AddStocktakingIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :stocktaking_id, :string
  end
end
