class PalletPurchasePositionAssignmentsController < ApplicationController
  before_filter :load_parcel
  before_filter :prepare_line_items, :only => [:create_multiple, :destroy_multiple]
  after_filter :destroy_empty_pallets, :only => [:create_multiple]
  
  def create_multiple
    @items_with_quantity.delete_if{ |line_item| line_item["quantity"].to_i == 0 }
    
    @items_with_quantity.each do |item|
      purchase_position = PurchasePosition.where(:id => item["purchase_position_id"]).first
      item_quantity = PalletPurchasePositionAssignment.where(:pallet_id => @parcel.id, :purchase_position_id => item["purchase_position_id"]).sum(:quantity)
      
      args = {:pallet_id => @parcel.id, :purchase_position_id => purchase_position.id, :is_individual_package => item["is_individual_package"]}
      line_item = PalletPurchasePositionAssignment.where(args).first
      
      if line_item
        # Update existing line_item
        if (item_quantity < purchase_position.quantity) && (item["quantity"].to_i <= (purchase_position.quantity - item_quantity))
          line_item.update_attributes(:quantity => line_item.quantity + item["quantity"].to_i)
        end
      else
        # create new line_item
        if (item_quantity < purchase_position.quantity) && (item["quantity"].to_i <= (purchase_position.quantity - item_quantity))
          @parcel.line_items.create(:purchase_position_id => purchase_position.id, :quantity => item["quantity"], :is_individual_package => item["is_individual_package"])
        end
      end
    end
    if @parcel.line_items.size > 0
      @parcel.purchase_order_ids = self.fetch_purchase_orders.collect(&:id)
    end
    
    redirect_to(:back, @parcel.valid? ? {:notice => 'Not translated...'} : {:error => 'Not translated...'})
  end
  
  def destroy_multiple
    @items_with_quantity.each do |item|
      purchase_position = PurchasePosition.where(:id => item["purchase_position_id"]).first
      item_quantity = PalletPurchasePositionAssignment.where(:pallet_id => @parcel.id, :purchase_position_id => item["purchase_position_id"]).sum(:quantity)
      
      #args = {:pallet_id => @parcel.id, :purchase_position_id => purchase_position.id}
      line_item = PalletPurchasePositionAssignment.where(:id => item["id"]).first
      
      if (item["quantity"].to_i == 0)
        # destroy line_item
        if line_item
          line_item.destroy
        end
      else
        # update line_item
        if (item["quantity"].to_i <= line_item.quantity)
          line_item.update_attributes(:quantity => item["quantity"].to_i)
        else
          if (((item["quantity"].to_i - line_item.quantity) + item_quantity) <= purchase_position.quantity)
            line_item.update_attributes(:quantity => item["quantity"].to_i)
          end
        end
      end
    end
    
    redirect_to(:back, {:notice => "asdfasdf"})
  end
  
  protected
  
  def load_parcel
    @parcel = Pallet.where(:id => params[:pallet_id]).first
    unless @parcel.present?
      @parcel = Pallet.create
    end
    
    return @parcel
  end
  
  def prepare_line_items
    @items_with_quantity = params[:line_items]
    @items_with_quantity.delete_if{ |line_item| line_item["quantity"].blank? }
    
    @purchase_position_ids = @items_with_quantity.collect{ |line_item| line_item["purchase_position_id"] }
  end
  
  def fetch_purchase_orders
    return PurchaseOrder.where("purchase_positions.id IN (?)", @parcel.purchase_positions.collect(&:id)).joins(:purchase_positions).select("distinct(purchase_orders.id)")
  end
  
  def destroy_empty_pallets
    Pallet.where(:line_items_quantity => 0).destroy_all
  end
  
end
