class PurchaseOrdersController < ApplicationController
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_positions = @purchase_order.purchase_positions.where('pallet_id IS NULL')
    @pallets = @purchase_order.pallets
    @mixed_purchase_positions = @purchase_order.purchase_positions.where("purchase_order_id IS NOT NULL AND")
  end
  
  def search_for
    @purchase_order = PurchaseOrder.where(:baan_id => params[:purchase_order_id])
    if @purchase_order.present?
      redirect_to purchase_order_url(@purchase_order.first)
    end
  end

  def index
    if params[:search].present? && params[:search][:delivered_equals].present? && params[:search][:delivered_equals] == "true"
      @search = PurchaseOrder.where(:status => "open").where("customer_id IS NOT NULL").search(params[:search])
    else
      @search = PurchaseOrder.where(:status => "open").where(:delivered => false).where("customer_id IS NOT NULL").search(params[:search])
    end
    
    @purchase_orders = @search.order("shipping_route_id asc, purchase_positions.consignee_full asc, purchase_orders.delivery_date asc, purchase_orders.id asc").includes(:purchase_positions).select("purchase_positions.consignee_full")
  end
  
  def edit
    @purchase_order = PurchaseOrder.find(params[:id])
  end
  
  def update
    @purchase_order = PurchaseOrder.find(params[:id])
    if @purchase_order.update_attributes(params[:purchase_order])
      redirect_to(:back)
    else
      render 'edit'
    end
  end
  
  def print_pallets
    @purchase_order = PurchaseOrder.find(params[:id])
    @pallets = @purchase_order.pallets
    @purchase_positions = @purchase_order.purchase_positions.where('pallet_id IS NOT NULL')
    
    @foreign_purchase_positions = []
    @pallets.each do |pallet|
      pallet.purchase_positions.each do |purchase_position|
        if purchase_position.purchase_order_id != @purchase_order.id
          @foreign_purchase_positions << purchase_position
        end
      end
    end
    
    respond_to do |format|
      format.pdf do
        render( 
          :pdf => "paletten_liste_VK##{@purchase_order.baan_id}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8',
          :header => {
            :left => "Fraefel AG",
            :right => "VK-Auftrag NR #{@purchase_order.baan_id}",
            :line => true,
            :spacing => 2
          },
          :footer => {
            :left => "#{purchase_order_url(@purchase_order)}",
            :right => "Seite [page]",
            :line => true
          }
        )
      end
    end
  end
  
  def import_orders
    #system('rake routes')
    system('rake baan:import:re RAILS_ENV=production')
    redirect_to(:back)
  end
end
