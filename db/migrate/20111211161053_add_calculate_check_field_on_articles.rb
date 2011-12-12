class AddCalculateCheckFieldOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :should_be_checked, :boolean
  end

  def self.down
    remove_column :articles, :should_be_checked
  end
end