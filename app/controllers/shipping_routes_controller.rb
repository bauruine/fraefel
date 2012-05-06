class ShippingRoutesController < ApplicationController
  
  def index
    @shipping_routes = ShippingRoute.includes(:purchase_orders).order("name ASC")
    
    respond_to do |format|
      format.json
    end
  end
  
end
