class PurchaseOrdersController < ApplicationController
  filter_access_to :all
  before_filter :is_currently_importing, :only => :index
  
  def show
    @purchase_order = PurchaseOrder.where(:id => params[:id]).first
    @purchase_positions = PurchasePosition.where(:purchase_order_id => @purchase_order.id).where("purchase_positions.cancelled" => false)
    @pallets = Pallet.where("purchase_orders.id = ?", @purchase_order.id).includes([:purchase_orders => :shipping_address], [:purchase_positions => :shipping_address])
    @mixed_purchase_positions = @purchase_order.purchase_positions.where("purchase_order_id IS NOT NULL")
    @shipping_routes = ShippingRoute.order("name ASC")
    @purchase_order_categories = Category.order("title ASC").where(:categorizable_type => "purchase_order")
    
    @commodity_codes = CommodityCode.all
    
    
    respond_to do |format|
      format.html
      format.pdf do
        render( 
          :pdf => "fraefel_app-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8',
          :footer => {
            :left => "#{Time.now.to_formatted_s(:swiss_date)}",
            :right => "Seite [page] / [topage]",
            :line => false
          }
        )
      end
    end
    
  end
  
  def search_for
    @purchase_order = PurchaseOrder.where(:baan_id => params[:purchase_order_id])
    if @purchase_order.present?
      redirect_to purchase_order_url(@purchase_order.first)
    end
  end

  def index
    @search = PurchaseOrder.includes({:purchase_positions => [:zip_location]}, :shipping_route, :calculation, :shipping_address).search(params[:q] || {:delivered_eq => "false", :picked_up_eq => "false", :cancelled_eq => "false"})
    @purchase_orders = @search.result.ordered_for_delivery
    
    @purchase_order_ids = @purchase_orders.collect(&:id)
    
    @level_1 = Address.select("DISTINCT `addresses`.*").where("addresses.category_id = ?", 8).where("purchase_orders.id" => @purchase_order_ids).joins(:purchase_orders)
    @level_2 = Address.select("DISTINCT `addresses`.*").where("addresses.category_id = ?", 9).where("purchase_orders.id" => @purchase_order_ids).joins(:purchase_orders)
    @level_3 = Address.select("DISTINCT `addresses`.*").where("addresses.category_id = ?", 10).where("purchase_orders.id" => @purchase_order_ids).joins(:purchase_orders)
    
    @shipping_routes = ShippingRoute.select("DISTINCT `shipping_routes`.*").where("purchase_orders.id" => @purchase_order_ids).joins(:purchase_orders)
    @purchase_order_categories = Category.order("title ASC").where(:categorizable_type => "purchase_order")
    
    @production_status_count = PurchasePosition.where("purchase_orders.id" => @purchase_order_ids, "purchase_positions.production_status" => 1).joins(:purchase_order).count("DISTINCT `purchase_positions`.id")
    @stock_status_count = PurchasePosition.where("purchase_orders.id" => @purchase_order_ids, "purchase_positions.stock_status" => 1).joins(:purchase_order).count("DISTINCT `purchase_positions`.id")
    @pending_status_count = PurchasePosition.where("purchase_orders.id" => @purchase_order_ids, "purchase_positions.production_status" => 0, "purchase_positions.stock_status" => 0).joins(:purchase_order).count("DISTINCT `purchase_positions`.id")
    respond_to do |format|
      format.html
      format.js
      format.json
      format.xml
      format.pdf do
        render( 
          :pdf => "print-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8',
          :footer => {
            :right => params[:pdf_type] != "invoice" ? "Seite [page] / [topage]" : "",
            :left => params[:pdf_type] != "invoice" ? "#{Time.now.to_formatted_s(:swiss_date)}" : "",
            :line => false
          }
        )
      end
    end
  end
  
  def edit
    @purchase_order = PurchaseOrder.find(params[:id])
  end
  
  def update
    @purchase_order = PurchaseOrder.find(params[:id])
    
    respond_to do |format|
      if @purchase_order.update_attributes(params[:purchase_order])
        format.html { redirect_to @purchase_order, notice: 'VK wurde erfolgreich gespeichert.' }
        format.js
      else
        format.html { render action: "edit" }
        format.js
      end
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
          :pdf => "print_VK##{@purchase_order.baan_id}",
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
  
  def destroy_multiple
    Resque.enqueue(FraefelJaintor)
    redirect_to purchase_orders_path
  end
  
  private
  
  def method_name
    if params[:search].present?
      
    end
  end
  
  def is_currently_importing
    unless Resque::Worker.working.empty?
      render "shared/disabled_while_importing"
    end
  end
end
