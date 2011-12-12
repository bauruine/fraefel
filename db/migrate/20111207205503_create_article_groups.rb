class CreateArticleGroups < ActiveRecord::Migration
  def self.up
    create_table :article_groups do |t|
      t.text :description
      t.integer :warn_on
      t.integer :baan_id

      t.timestamps
    end
  end

  def self.down
    drop_table :article_groups
  end
end
