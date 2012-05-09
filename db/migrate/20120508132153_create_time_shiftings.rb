class CreateTimeShiftings < ActiveRecord::Migration
  def self.up
    create_table :time_shiftings do |t|
      t.boolean :simple
      t.integer :purchase_order_id
      t.date :delivery_date
      
      t.integer :created_by
      t.integer :updated_by
      
      t.timestamps
    end
  end

  def self.down
    drop_table :time_shiftings
  end
end
