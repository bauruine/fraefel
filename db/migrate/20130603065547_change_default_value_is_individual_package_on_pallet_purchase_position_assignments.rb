class ChangeDefaultValueIsIndividualPackageOnPalletPurchasePositionAssignments < ActiveRecord::Migration
  def up
    change_column :pallet_purchase_position_assignments, :is_individual_package, :boolean, :default => false
  end

  def down
    change_column :pallet_purchase_position_assignments, :is_individual_package, :boolean, :default => false
  end
end