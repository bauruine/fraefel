class CreateShiftingReasons < ActiveRecord::Migration
  def self.up
    create_table :shifting_reasons do |t|
      t.string :title
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :shifting_reasons
  end
end
