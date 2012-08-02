class Api::PurchasePositionsController < ApplicationController
  
  def index
    @search = PurchasePosition.search(params[:q])
    @purchase_positions = @search.result
    
    respond_to do |format|
      format.xml
    end
  end
  
end
