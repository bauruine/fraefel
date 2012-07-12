class RemoveZipStreetCityVatAmountSubtotalTotalAmountFromCargoLists < ActiveRecord::Migration
  def self.up
    remove_column :cargo_lists, :zip
    remove_column :cargo_lists, :street
    remove_column :cargo_lists, :city
    remove_column :cargo_lists, :vat
    remove_column :cargo_lists, :effective_invoice_amount
    remove_column :cargo_lists, :subtotal
    remove_column :cargo_lists, :total_amount
  end

  def self.down
    add_column :cargo_lists, :total_amount, :decimal, :precision => 12, :scale => 2
    add_column :cargo_lists, :subtotal, :decimal, :precision => 12, :scale => 2
    add_column :cargo_lists, :effective_invoice_amount, :decimal, :precision => 12, :scale => 2
    add_column :cargo_lists, :vat, :decimal, :precision => 12, :scale => 2
    add_column :cargo_lists, :city, :string
    add_column :cargo_lists, :street, :string
    add_column :cargo_lists, :zip, :integer
  end
end
