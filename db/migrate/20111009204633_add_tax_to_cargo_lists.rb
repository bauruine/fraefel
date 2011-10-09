class AddTaxToCargoLists < ActiveRecord::Migration
  def self.up
    add_column :cargo_lists, :vat, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    remove_column :cargo_lists, :vat
  end
end
