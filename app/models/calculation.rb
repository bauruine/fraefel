class Calculation < ActiveRecord::Base
  belongs_to :calculable, :polymorphic => true
  
  def recalculate_total_pallets
    if self.calculable.class.name == PurchaseOrder.name
      self.update_column(:total_pallets, self.calculable.pallets.count)
    end
  end
  
  def recalculate_total_purchase_positions
    if self.calculable.class.name == PurchaseOrder.name
      self.update_column(:total_purchase_positions, self.calculable.purchase_positions.where("purchase_positions.cancelled" => false).count)
    end
  end
  
end
