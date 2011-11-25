class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :baan_acces_id
      t.string :article_code
      t.integer :depot_code
      t.integer :article_type
      t.string :signal_code_description
      t.string :description
      t.string :search_key_01
      t.string :search_key_02
      t.string :material
      t.string :factor
      t.string :zone_code
      t.string :stock_unit
      t.string :order_unit
      t.string :trade_partner_name
      t.string :trade_partner_additional_info
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
