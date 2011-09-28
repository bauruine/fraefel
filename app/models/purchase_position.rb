class PurchasePosition < ActiveRecord::Base
  belongs_to :commodity_code, :class_name => "CommodityCode", :foreign_key => "commodity_code_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  
  after_save :update_purchase_order_date
  
  
  protected
  
  def update_purchase_order_date
    @purchase_order = self.purchase_order
    @date_for_update = @purchase_order.purchase_positions.order("delivery_date asc").limit(1).first.delivery_date.to_date
    @purchase_order.update_attributes(:delivery_date => @date_for_update)
  end
end
