# encoding: utf-8

class PurchaseOrdersController < FraefelController

  filter_access_to :all
  before_filter :is_currently_importing, :only => :index

  def show
    @purchase_order = PurchaseOrder.where(:id => params[:id]).first
    @purchase_positions = PurchasePosition.where(:purchase_order_id => @purchase_order.id).where("purchase_positions.cancelled" => false)
    @pallets = Pallet.where("purchase_orders.id = ?", @purchase_order.id).includes([:purchase_orders => :shipping_address], [:purchase_positions => :shipping_address])
    @parcels = @pallets
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
    ActiveRecord::Base.logger.level = 1
    @search = PurchaseOrder.includes(:zip_location, :shipping_route, :calculation, :shipping_address)
                           .search(params[:q] || { delivered_eq: 'false', picked_up_eq: 'false', cancelled_eq: 'false' })

    @purchase_order_ids = @search.result.pluck(:id)
    @test = PurchaseOrder.joins(:shipping_route, :zip_location, :calculation, :shipping_address)
                         .where(id: @purchase_order_ids)
                         .ordered_for_delivery
                         .pluck_all('purchase_orders.stock_status', 'purchase_orders.pending_status', 'purchase_orders.production_status', 'calculations.total_pallets', 'DATE_FORMAT(purchase_orders.delivery_date, "%e.%m.%y") AS delivery_date', 'purchase_orders.id', 'purchase_orders.baan_id', 'shipping_routes.name AS shipping_route', 'zip_locations.title AS zip_location', 'CONCAT(addresses.company_name, ", ", addresses.street, ", ", addresses.country, "-", addresses.postal_code, " ", addresses.city) AS shipping_address')

    @level_1 = Address.joins(:purchase_orders)
                      .where("addresses.category_id" => 8, "purchase_orders.id" => @purchase_order_ids)
                      .uniq('addresses.id')
                      .pluck_all('addresses.id', 'CONCAT(addresses.company_name, ", ", addresses.street, ", ", addresses.country, "-", addresses.postal_code, " ", addresses.city) AS label')
    @level_2 = Address.joins(:purchase_orders)
                      .where("addresses.category_id" => 9, "purchase_orders.id" => @purchase_order_ids)
                      .uniq('addresses.id')
                      .pluck_all('addresses.id', 'CONCAT(addresses.company_name, ", ", addresses.street, ", ", addresses.country, "-", addresses.postal_code, " ", addresses.city) AS label')
    @level_3 = Address.joins(:purchase_orders)
                      .where("addresses.category_id" => 10, "purchase_orders.id" => @purchase_order_ids)
                      .uniq('addresses.id')
                      .pluck_all('addresses.id', 'CONCAT(addresses.company_name, ", ", addresses.street, ", ", addresses.country, "-", addresses.postal_code, " ", addresses.city) AS label')

    @shipping_routes = ShippingRoute.joins(:purchase_orders)
                                    .where("purchase_orders.id" => @purchase_order_ids)
                                    .order("shipping_routes.name ASC")
                                    .uniq('shipping_routes.id')
                                    .pluck_all('shipping_routes.id', 'shipping_routes.name AS label')

    @purchase_order_categories = Category.where(categorizable_type: 'purchase_order')
                                         .order("categories.title ASC")
                                         .uniq('categories.id')
                                         .pluck_all('categories.id', 'categories.title AS label')

    @production_status_count  = PurchasePosition.joins(:purchase_order)
                                                .where("purchase_orders.id" => @purchase_order_ids, "purchase_positions.production_status" => 1)
                                                .count("DISTINCT purchase_positions.id")
    @stock_status_count       = PurchasePosition.joins(:purchase_order)
                                                .where("purchase_orders.id" => @purchase_order_ids, "purchase_positions.stock_status" => 1)
                                                .count("DISTINCT purchase_positions.id")
    @pending_status_count     = PurchasePosition.joins(:purchase_order)
                                                .where("purchase_orders.id" => @purchase_order_ids, "purchase_positions.production_status" => 0, "purchase_positions.stock_status" => 0)
                                                .count("DISTINCT purchase_positions.id")

    respond_to do |format|
      format.html
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
    @purchase_order_categories = Category.order("title ASC").where(:categorizable_type => "purchase_order")
    @shipping_routes = ShippingRoute.order("name ASC")


  end

  def update
    @purchase_order = PurchaseOrder.find(params[:id])

    if @purchase_order.update_attributes(params[:purchase_order])
      redirect_to @purchase_order, notice: 'VK wurde erfolgreich gespeichert.'
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
    unless Redis.connect.smembers('workers').empty?
      render "shared/disabled_while_importing"
    end
  end
end
