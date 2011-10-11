class PurchasePositionsController < ApplicationController
  def show
    @purchase_position = PurchasePosition.find(params[:id])
    @purchase_order = @purchase_position.where
  end
  
  def index
    if params[:to_be_checked] && params[:to_be_checked] == "true"
      @purchase_orders = PurchaseOrder.where("purchase_positions.amount = 0 OR purchase_positions.quantity = 0 OR purchase_positions.weight_single = 0").includes(:purchase_positions)
    else
      @purchase_orders = PurchaseOrder.all
    end
  end
  
  def edit
    @purchase_position = PurchasePosition.find(params[:id])
  end
  
  def update
    @purchase_position = PurchasePosition.find(params[:id])
    calculated_amount = @purchase_position.amount * @purchase_position.quantity
    if @purchase_position.update_attributes(params[:purchase_position])
      @purchase_position.update_attributes(:total_amount => calculated_amount)
      redirect_to(:back)
    else
      render 'edit'
    end
  end
end
