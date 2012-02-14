class CreateReferees < ActiveRecord::Migration
  def self.up
    create_table :referees do |t|
      t.integer :customer_id
      t.string :forename
      t.string :surname
      t.string :phone_number
      t.string :email
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :referees
  end
end
