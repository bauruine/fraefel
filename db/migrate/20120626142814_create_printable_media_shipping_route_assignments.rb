class CreatePrintableMediaShippingRouteAssignments < ActiveRecord::Migration
  def self.up
    create_table :printable_media_shipping_route_assignments do |t|
      t.integer :printable_media_id
      t.integer :shipping_route_id
    end
  end

  def self.down
    drop_table :printable_media_shipping_route_assignments
  end
end
