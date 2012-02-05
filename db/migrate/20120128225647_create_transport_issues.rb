class CreateTransportIssues < ActiveRecord::Migration
  def self.up
    create_table :transport_issues do |t|
      t.integer :purchase_position_id
      t.integer :delivery_rejection_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :transport_issues
  end
end
