class ShippingRoutesController < ApplicationController
  
  def index
    @shipping_routes = ShippingRoute.order("name ASC")
    
    respond_to do |format|
      format.html
      format.xml
    end
  end
  
  
  def edit
    @shipping_route = ShippingRoute.where(:id => params[:id]).first
  end
  
  def update
    @shipping_route = ShippingRoute.where(:id => params[:id]).first
    @shipping_route.attributes = params[:shipping_route] if @shipping_route.present?
    if @shipping_route.save
      redirect_to shipping_routes_path()
    else
      render 'edit'
    end
  end
  
end
