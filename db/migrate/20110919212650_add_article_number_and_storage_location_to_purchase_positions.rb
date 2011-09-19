class AddArticleNumberAndStorageLocationToPurchasePositions < ActiveRecord::Migration
  def self.up
    add_column :purchase_positions, :storage_location, :string
    add_column :purchase_positions, :article_number, :string
  end

  def self.down
    remove_column :purchase_positions, :storage_location
    remove_column :purchase_positions, :article_number
  end
end
