class CreateDeliveryDates < ActiveRecord::Migration
  def self.up
    create_table :delivery_dates do |t|
      t.date :date_of_delivery
      t.references :dateable, :polymorphic => true
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_dates
  end
end
