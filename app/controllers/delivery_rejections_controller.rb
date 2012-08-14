class DeliveryRejectionsController < ApplicationController
  filter_access_to :all
  
  def show
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @cargo_lists = @delivery_rejection.cargo_lists
    @purchase_positions = PurchasePosition.where("delivery_rejections.id = ?", @delivery_rejection.id).includes(:pallets => :delivery_rejection)
    @pallets = Pallet.where("pallets.delivery_rejection_id" => @delivery_rejection.id)
    @coli_count = Pallet.joins(:pallet_type).where("pallets.delivery_rejection_id" => @delivery_rejection.id, "pallet_types.description" => "coli").count("DISTINCT pallets.id")
    @referee = @delivery_rejection.referee
    @address = @delivery_rejection.address
    
    @delivery_address = @delivery_rejection.delivery_address
    @invoice_address = @delivery_rejection.invoice_address
    @pick_up_address = @delivery_rejection.pick_up_address
    
    @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.select("DISTINCT `pallet_purchase_position_assignments`.*").joins(:pallet => :delivery_rejection).where("delivery_rejections.id" => @delivery_rejection.id)
    @pallet_types = PalletType.joins(:pallets).where("pallets.delivery_rejection_id" => @delivery_rejection.id)
    
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
    @search = DeliveryRejection.search(params[:q] || {:closed_eq => false})
    @delivery_rejections = @search.result.order("delivery_rejections.id DESC")
    @delivery_rejection_ids = @delivery_rejections.collect(&:id)
    @address_category = Category.where(:title => "Abholadresse").first
    @addresses = Address.select("DISTINCT `addresses`.*").joins(:delivery_rejection).where("delivery_rejections.id" => @delivery_rejection_ids, "addresses.category_id" => @address_category.id)
    @categories = Category.select("DISTINCT `categories`.*").joins(:delivery_rejections).where("delivery_rejections.id" => @delivery_rejection_ids)
    @statuses = Status.select("DISTINCT `statuses`.*").joins(:delivery_rejections).where("delivery_rejections.id" => @delivery_rejection_ids)
    @customers = Customer.select("DISTINCT `customers`.*").joins(:delivery_rejections).where("delivery_rejections.id" => @delivery_rejection_ids)
  end
  
  def new
    @delivery_rejection = DeliveryRejection.new
    @comment = @delivery_rejection.comments.build
    @search = PurchasePosition.search(params[:q])
  end
  
  def create
    @delivery_rejection = DeliveryRejection.new(params[:delivery_rejection])
    #@comment = @delivery_rejection.comments.build
    @search = PurchasePosition.search(params[:q])
    
    if @delivery_rejection.save
      redirect_to delivery_rejection_url(@delivery_rejection)
    else
      render 'new'
    end
  end
  
  def edit
    @delivery_rejection = DeliveryRejection.find(params[:id])
    @comment = @delivery_rejection.comments.build

    @delivery_rejection.build_referee if @delivery_rejection.referee.nil?
    @delivery_rejection.build_new_delivery_address if @delivery_rejection.new_delivery_address.nil?
    @delivery_rejection.build_new_pick_up_address if @delivery_rejection.new_pick_up_address.nil?
    @delivery_rejection.build_new_invoice_address if @delivery_rejection.new_invoice_address.nil?
    
    @delivery_addresses = Address.where(:category_id => 3).order("company_name ASC")
    @invoice_addresses = Address.where(:category_id => 14).order("company_name ASC")
    @pick_up_addresses = Address.where(:category_id => 4).order("company_name ASC")
    
    @search = PurchasePosition.search(params[:q])
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
      pallet_purchase_position_assignment = PalletPurchasePositionAssignment.where(:pallet_id => @pallet.id, :purchase_position_id => purchase_position.id).first
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
  
  def search
    @cargo_list = CargoList.where("purchase_orders.baan_id = ?", params[:purchase_order_baan_id]).includes(:pallets => :purchase_orders)
    respond_to do |format|
      format.js
    end
  end
end
