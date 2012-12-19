class AddStocktakingIdToDepots < ActiveRecord::Migration
  def change
    add_column :depots, :stocktaking_id, :string
  end
end
