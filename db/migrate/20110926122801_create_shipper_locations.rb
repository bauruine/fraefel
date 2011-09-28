class CreateShipperLocations < ActiveRecord::Migration
  def self.up
    create_table :shipper_locations do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :shipper_locations
  end
end
