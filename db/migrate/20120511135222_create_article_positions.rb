class CreateArticlePositions < ActiveRecord::Migration
  def self.up
    create_table :article_positions do |t|
      t.string :baan_id
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :article_positions
  end
end
