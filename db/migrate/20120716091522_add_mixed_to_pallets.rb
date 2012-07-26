class AddMixedToPallets < ActiveRecord::Migration
  def self.up
    add_column :pallets, :mixed, :boolean, :default => false
    
    #Pallet.joins(:purchase_orders).readonly(false).each do |pallet|
    #  if pallet.purchase_orders.uniq.size > 1
    #    pallet.update_attributes(:mixed => true)
    #  end
    #end
  end

  def self.down
    remove_column :pallets, :mixed
  end
end
