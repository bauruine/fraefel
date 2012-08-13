class AddClosedToDeliveryRejections < ActiveRecord::Migration
  def change
    add_column :delivery_rejections, :closed, :boolean, :default => false
  end
end
