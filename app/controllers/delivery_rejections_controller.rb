class DeliveryRejectionsController < ApplicationController
  def show
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @cargo_list = @delivery_rejection.cargo_list
    @purchase_positions = PurchasePosition.where("delivery_rejections.id = ?", @delivery_rejection.id).includes(:pallets => :delivery_rejection)
    @pallets = @delivery_rejection.pallets
    @referee = @delivery_rejection.referee
    @address = @delivery_rejection.address
    
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
      redirect_to edit_delivery_rejection_url(@delivery_rejection)
    else
      render 'new'
    end
  end
  
  def edit
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @comment = @delivery_rejection.comments.build
    if @delivery_rejection.referee.nil?
      @referee = @delivery_rejection.build_referee
    end
    @search = PurchasePosition.search(params[:search])
    if @delivery_rejection.addresses.empty?
        @delivery_rejection.addresses.build(:category_id => 4)
        @delivery_rejection.addresses.build(:category_id => 3)
    end
  end
  
  def update
    @delivery_rejection = DeliveryRejection.find(params[:id])
    #@comment = @delivery_rejection.comments.build
    #@search = PurchasePosition.search(params[:search])
    
    if @delivery_rejection.update_attributes(params[:delivery_rejection])
      redirect_to delivery_rejection_path(@delivery_rejection)
    else
      render 'edit'
    end
  end
  
  def destroy
    
  end
  
  def assign_positions
    @delivery_rejection = DeliveryRejection.where(:id => params[:delivery_rejection_id]).first
    if params[:pallet_id].present?
      @pallet = Pallet.where(:id => params[:pallet_id]).first
      @pallet.purchase_positions += PurchasePosition.where(:id => params[:purchase_position_ids])
      @delivery_rejection.pallets += [@pallet]
    else
      @pallet = Pallet.new
      @pallet.save
      @pallet.purchase_positions += PurchasePosition.where(:id => params[:purchase_position_ids])
      @delivery_rejection.pallets += [@pallet]
    end
    params[:quantity_with_ids].each do |k, v|
      purchase_position = PurchasePosition.find(k.to_i)
      pallet_purchase_position_assignment = PalletPurchasePositionAssignment.where(:pallet => @pallet, :purchase_position => purchase_position).first
      pallet_purchase_position_assignment.update_attributes(:reduced_price => (((pallet_purchase_position_assignment.purchase_position.amount * v.to_i) / 100) * @delivery_rejection.discount), :quantity => v.to_i, :amount => (pallet_purchase_position_assignment.purchase_position.amount * v.to_i), :weight => (pallet_purchase_position_assignment.purchase_position.weight_single * v.to_i)) if pallet_purchase_position_assignment.present?
    end
    redirect_to(:back)
  end
  
  def remove_positions
    @pallet = Pallet.find(params[:pallet_id])
    @purchase_positions = PurchasePosition.where(:id => params[:purchase_position_ids])
    @pallet.purchase_positions -= @purchase_positions
    if @pallet.purchase_positions.empty?
      @pallet.update_attribute(:delivery_rejection_id, nil)
    end
    redirect_to(:back)
  end
  
end
