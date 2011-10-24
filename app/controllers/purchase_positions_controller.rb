class PurchasePositionsController < ApplicationController
  filter_access_to :all
  def show
    @purchase_position = PurchasePosition.find(params[:id])
    @purchase_order = @purchase_position.where
  end
  
  def search_for
    extracted_purchase_order_id = params[:purchase_position_id].split("-")[0]
    @purchase_order = PurchaseOrder.where(:baan_id => extracted_purchase_order_id)
    if @purchase_order.present?
      redirect_to purchase_order_url(@purchase_order.first)
    end
  end
  
  def index
    if params[:to_be_checked] && params[:to_be_checked] == "true"
      @purchase_orders = PurchaseOrder.where("purchase_positions.amount = 0 OR purchase_positions.quantity = 0 OR purchase_positions.weight_single = 0").where("purchase_positions.delivered = false or purchase_positions.delivered IS NULL").includes(:purchase_positions)
    else
      @purchase_orders = PurchaseOrder.where("purchase_positions.delivered = false or purchase_positions.delivered IS NULL").includes(:purchase_positions)
    end
  end
  
  def edit
    @purchase_position = PurchasePosition.find(params[:id])
  end
  
  def update
    @purchase_position = PurchasePosition.find(params[:id])
    if @purchase_position.update_attributes(params[:purchase_position])
      redirect_to(:back)
    else
      render 'edit'
    end
  end
end
