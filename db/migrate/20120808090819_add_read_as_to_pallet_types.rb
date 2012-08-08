class AddReadAsToPalletTypes < ActiveRecord::Migration
  def change
    add_column :pallet_types, :read_as, :string
  end
end
