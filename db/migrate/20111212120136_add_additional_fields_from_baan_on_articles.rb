class AddAdditionalFieldsFromBaanOnArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :baan_orno, :string
    add_column :articles, :baan_cntn, :string
    add_column :articles, :baan_pono, :string
    add_column :articles, :baan_loca, :string
    add_column :articles, :baan_clot, :string
    add_column :articles, :baan_qstk, :string
    add_column :articles, :baan_qstr, :string
    add_column :articles, :baan_csts, :string
    add_column :articles, :baan_recd, :string
  end

  def self.down
    remove_column :articles, :baan_recd
    remove_column :articles, :baan_csts
    remove_column :articles, :baan_qstr
    remove_column :articles, :baan_qstk
    remove_column :articles, :baan_clot
    remove_column :articles, :baan_loca
    remove_column :articles, :baan_pono
    remove_column :articles, :baan_cntn
    remove_column :articles, :baan_orno
  end
end