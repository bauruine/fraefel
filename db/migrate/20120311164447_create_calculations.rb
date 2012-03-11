class CreateCalculations < ActiveRecord::Migration
  def self.up
    create_table :calculations do |t|
      t.integer :total_pallets
      t.integer :total_purchase_positions
      t.references :calculable, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :calculations
  end
end
