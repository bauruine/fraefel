class CreateShippers < ActiveRecord::Migration
  def self.up
    create_table :shippers do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :shippers
  end
end
