class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :title
      t.text :description
      t.integer :created_by
      t.integer :updated_by
      t.string :statusable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end
