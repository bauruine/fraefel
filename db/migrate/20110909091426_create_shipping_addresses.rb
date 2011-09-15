class CreateShippingAddresses < ActiveRecord::Migration
  def self.up
    create_table :shipping_addresses do |t|
      t.string :street
      t.integer :zip
      t.string :city
      t.string :country
      t.string :fax
      t.string :phone_number
      t.integer :customer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_addresses
  end
end
