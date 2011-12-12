class AddMoreAdditionalFieldsOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :baan_item, :string
    add_column :articles, :baan_date, :string
    add_column :articles, :baan_stun, :string
    add_column :articles, :baan_reco, :string
    add_column :articles, :baan_appr, :string
    add_column :articles, :baan_cadj, :string
    add_column :articles, :considered, :boolean
  end

  def self.down
    remove_column :articles, :considered
    remove_column :articles, :baan_cadj
    remove_column :articles, :baan_appr
    remove_column :articles, :baan_reco
    remove_column :articles, :baan_stun
    remove_column :articles, :baan_date
    remove_column :articles, :baan_item
  end
end