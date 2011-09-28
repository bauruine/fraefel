class CreateShippingRoutes < ActiveRecord::Migration
  def self.up
    create_table :shipping_routes do |t|
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_routes
  end
end
