class AddBaanIdToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :baan_id, :string
  end

  def self.down
    remove_column :customers, :baan_id
  end
end
