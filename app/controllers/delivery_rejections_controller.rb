class DeliveryRejectionsController < ApplicationController
  def show
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @purchase_positions = @delivery_rejection.purchase_positions
    respond_to do |format|
      format.html
      format.pdf do
        render( 
          :pdf => "Kein Titel-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8'
        )
        #purchase_positions.group(:commodity_code_id).sum(:amount)
      end
    end
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
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @comment = @delivery_rejection.comments.build
    @search = PurchasePosition.search(params[:search])
  end
  
  def update
    @delivery_rejection = DeliveryRejection.find(params[:id])
    #@comment = @delivery_rejection.comments.build
    @search = PurchasePosition.search(params[:search])
    
    if @delivery_rejection.update_attributes(params[:delivery_rejection])
      redirect_to delivery_rejections_url
    else
      render 'edit'
    end
  end
  
  def destroy
    
  end
  
end
