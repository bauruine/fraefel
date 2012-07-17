class AddLevel3ToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :level_3, :integer
    PalletPurchasePositionAssignment.where("pallets.id IS NOT NULL").where("purchase_positions.id IS NOT NULL").includes([:purchase_position => :shipping_address], :pallet).each do |pallet_purchase_position_assignment|
      @pallet = pallet_purchase_position_assignment.pallet
      @purchase_position = pallet_purchase_position_assignment.purchase_position
      @address_id = @purchase_position.level_3
      
      @pallet.update_attribute("level_3", @address_id)
    end
  end

  def self.down
    remove_column :pallets, :level_3
  end
end