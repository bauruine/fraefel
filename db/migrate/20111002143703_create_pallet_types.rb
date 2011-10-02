class CreatePalletTypes < ActiveRecord::Migration
  def self.up
    create_table :pallet_types do |t|
      t.string :description
      t.float :count_as

      t.timestamps
    end
    PalletType.create(:description => "halb", :count_as => 0.5)
    PalletType.create(:description => "ganz", :count_as => 1)
    PalletType.create(:description => "doppelt", :count_as => 2)
  end

  def self.down
    drop_table :pallet_types
  end
end
