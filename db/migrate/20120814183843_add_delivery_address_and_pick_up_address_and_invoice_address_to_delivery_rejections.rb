class AddDeliveryAddressAndPickUpAddressAndInvoiceAddressToDeliveryRejections < ActiveRecord::Migration
  def change
    add_column :delivery_rejections, :delivery_address_id, :integer
    add_column :delivery_rejections, :pick_up_address_id, :integer
    add_column :delivery_rejections, :invoice_address_id, :integer
  end
end
