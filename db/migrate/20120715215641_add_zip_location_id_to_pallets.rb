class AddZipLocationIdToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :zip_location_id, :integer
    
    PalletPurchasePositionAssignment.reset_column_information
    
    PalletPurchasePositionAssignment.where("pallets.id IS NOT NULL").where("purchase_positions.id IS NOT NULL").includes([:purchase_position => :shipping_address], :pallet).each do |pallet_purchase_position_assignment|
      @pallet = pallet_purchase_position_assignment.pallet
      @purchase_position = pallet_purchase_position_assignment.purchase_position
      @zip_location_id = @purchase_position.zip_location_id
      
      @pallet.update_attribute("zip_location_id", @zip_location_id)
    end
    
  end

  def self.down
    remove_column :pallets, :zip_location_id
  end
end
