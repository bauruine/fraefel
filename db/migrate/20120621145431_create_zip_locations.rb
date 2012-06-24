class CreateZipLocations < ActiveRecord::Migration
  def self.up
    create_table :zip_locations do |t|
      t.string :title
    end
    PurchasePosition.all.each do |purchase_position|
      @zip_location = ZipLocation.find_or_create_by_title(:title => purchase_position.zip_location_name)
      purchase_position.update_attribute("zip_location_id", @zip_location.id)
    end
  end

  def self.down
    drop_table :zip_locations
  end
end
