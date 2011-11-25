class CreateDepotTypes < ActiveRecord::Migration
  def self.up
    create_table :depot_types do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :depot_types
  end
end
