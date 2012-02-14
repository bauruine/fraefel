class AddCargoListIdToDeliveryRejections < ActiveRecord::Migration
  def self.up
    add_column :delivery_rejections, :cargo_list_id, :integer
  end

  def self.down
    remove_column :delivery_rejections, :cargo_list_id
  end
end