class AddDiscountToDeliveryRejections < ActiveRecord::Migration
  def self.up
    add_column :delivery_rejections, :discount, :float
  end

  def self.down
    remove_column :delivery_rejections, :discount
  end
end