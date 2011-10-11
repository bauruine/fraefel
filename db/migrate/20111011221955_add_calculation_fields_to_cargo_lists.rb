class AddCalculationFieldsToCargoLists < ActiveRecord::Migration
  def self.up
    add_column :cargo_lists, :effective_invoice_amount, :decimal, :precision => 12, :scale => 2
    add_column :cargo_lists, :subtotal, :decimal, :precision => 12, :scale => 2
    add_column :cargo_lists, :total_amount, :decimal, :precision => 12, :scale => 2
  end

  def self.down
    add_column :cargo_lists, :effective_invoice_amount
    add_column :cargo_lists, :subtotal
    add_column :cargo_lists, :total_amount
  end
end
