class AddIsIndividualPackageToPalletPurchasePositionAssignments < ActiveRecord::Migration
  def change
    add_column :pallet_purchase_position_assignments, :is_individual_package, :boolean
  end
end
