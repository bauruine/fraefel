class DeliveryRejectionsController < ApplicationController
  def show
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @purchase_positions = @delivery_rejection.purchase_positions
  end
  
  def index
    @delivery_rejections = DeliveryRejection.all
  end
  
  def new
    @delivery_rejection = DeliveryRejection.new
    @comment = @delivery_rejection.comments.build
    @search = PurchasePosition.search(params[:search])
  end
  
  def create
    @delivery_rejection = DeliveryRejection.new(params[:delivery_rejection])
    #@comment = @delivery_rejection.comments.build
    @search = PurchasePosition.search(params[:search])
    
    if @delivery_rejection.save
      redirect_to delivery_rejections_url
    else
      render 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
end
