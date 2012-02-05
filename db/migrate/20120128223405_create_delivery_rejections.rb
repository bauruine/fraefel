class CreateDeliveryRejections < ActiveRecord::Migration
  def self.up
    create_table :delivery_rejections do |t|
      t.integer :customer_id
      t.integer :referee_id
      t.integer :address_id
      t.integer :category_id
      t.integer :status_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_rejections
  end
end
