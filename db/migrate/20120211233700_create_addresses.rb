class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.integer :customer_id
      t.string :street
      t.integer :postal_code
      t.string :city
      t.string :country
      t.integer :category_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
