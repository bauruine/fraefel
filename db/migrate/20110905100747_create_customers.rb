class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :company
      t.string :street
      t.string :city
      t.integer :zip
      t.string :country
      t.string :referee
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
