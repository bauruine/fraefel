class CreateCommodityCodes < ActiveRecord::Migration
  def self.up
    create_table :commodity_codes do |t|
      t.string :code
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :commodity_codes
  end
end
