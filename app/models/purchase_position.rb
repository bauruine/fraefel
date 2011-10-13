class PurchasePosition < ActiveRecord::Base
  belongs_to :commodity_code, :class_name => "CommodityCode", :foreign_key => "commodity_code_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  
  after_save :update_purchase_order_date
  after_update :update_weight_total
  
  scope :to_be_checked, where("amount = 0 OR weight_single = 0 OR quantity = 0")
  search_methods :to_be_checked
  
  protected
  
  def update_purchase_order_date
    @purchase_order = self.purchase_order
    @date_for_update = @purchase_order.purchase_positions.order("delivery_date asc").limit(1).first.delivery_date.to_date
    @purchase_order.update_attributes(:delivery_date => @date_for_update)
  end
  
  def update_weight_total
    @calculated_weight = (weight_single * quantity)
    if  @calculated_weight != weight_total
      update_attributes(:weight_total => @calculated_weight)
    end
  end
  
  def self.calculate_for_invoice(type, attrs)
    if attrs[1].present?
      sum("#{type}", :include => [:commodity_code, {:pallet => :cargo_list}], :conditions => {:cargo_lists => { :id => attrs[0] }, :commodity_codes => { :id => attrs[1] }})
    else
      sum("#{type}", :include => [:pallet => :cargo_list], :conditions => {:cargo_lists => { :id => attrs[0] }})
    end
  end
  
end
