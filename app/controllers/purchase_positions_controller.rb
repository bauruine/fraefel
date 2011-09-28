class PurchasePositionsController < ApplicationController
  def show
    @purchase_position = PurchasePosition.find(params[:id])
    @purchase_order = @purchase_position.where
  end
  
  def index
    
  end
  
  def edit
    @purchase_position = PurchasePosition.find(params[:id])
  end
  
  def update
    
  end
end
