class CreateDepots < ActiveRecord::Migration
  def self.up
    create_table :depots do |t|
      t.integer :code
      t.text :description
      t.integer :type
      t.string :address_code
      t.string :phone_number
      t.string :fax_number
      t.string :web_address

      t.timestamps
    end
  end

  def self.down
    drop_table :depots
  end
end
