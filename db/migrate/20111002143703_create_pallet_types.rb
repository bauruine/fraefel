class CreatePalletTypes < ActiveRecord::Migration
  def self.up
    create_table :pallet_types do |t|
      t.string :description
      t.float :count_as

      t.timestamps
    end
  end

  def self.down
    drop_table :pallet_types
  end
end
