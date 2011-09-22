class CreateCargoLists < ActiveRecord::Migration
  def self.up
    create_table :cargo_lists do |t|
      t.datetime :pick_up_time_earliest
      t.datetime :pick_up_time_latest
      t.timestamps
    end
  end

  def self.down
    drop_table :cargo_lists
  end
end
