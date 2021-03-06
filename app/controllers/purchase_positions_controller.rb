# encoding: utf-8

class PurchasePositionsController < FraefelController
  filter_access_to :all
  def show
    @purchase_position = PurchasePosition.find(params[:id])
    @purchase_order = @purchase_position.where
  end

  def search_for
    extracted_purchase_order_id = params[:purchase_position_id].split("-")[0]
    @purchase_order = PurchaseOrder.where(:baan_id => extracted_purchase_order_id)
    if @purchase_order.present?
      redirect_to purchase_order_url(@purchase_order.first)
    end
  end

  def index_beta
    @search = PurchasePosition.includes(:commodity_code, :purchase_order => :shipping_route).search(params[:search] || {:delivered_equals => "false", :stock_status_equals => 1})
    @purchase_positions = @search.relation.order("purchase_orders.shipping_route_id asc, purchase_orders.customer_id asc, purchase_positions.delivery_date asc, purchase_positions.stock_status desc, purchase_positions.production_status desc")
  end

  def index
    respond_to do |format|

      format.html do
        @search = PurchasePosition.includes(:commodity_code, :shipping_route, :html_content).search(params[:q] || {:delivered_eq => "false", :picked_up_eq => "false", :cancelled_eq => "false"})
        # @purchase_positions = @search.relation.order("purchase_orders.shipping_route_id asc, purchase_orders.customer_id asc, purchase_positions.delivery_date asc, purchase_positions.stock_status desc, purchase_positions.production_status desc")
        @purchase_positions = @search.result.order("purchase_positions.delivery_date asc, purchase_positions.level_3 asc, purchase_positions.shipping_route_id asc")
        @shipping_routes = ShippingRoute.order("name ASC")
        @commodity_codes = CommodityCode.all
      end

      format.pdf do
        @search = PurchasePosition.includes(:pallets, :commodity_code, :shipping_route).search(params[:q] || {:delivered_eq => "false", :picked_up_eq => "false", :cancelled_eq => "false"})
        # @purchase_positions = @search.relation.order("purchase_orders.shipping_route_id asc, purchase_orders.customer_id asc, purchase_positions.delivery_date asc, purchase_positions.stock_status desc, purchase_positions.production_status desc")
        @purchase_positions = @search.result
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

      format.js do
        @search = PurchasePosition.search(params[:search])
        @purchase_positions = @search.relation
      end
    end
  end

  def edit
    @purchase_position = PurchasePosition.find(params[:id])
    @purchase_order = @purchase_position.purchase_order

    @shipping_routes = ShippingRoute.order("name ASC")
    @commodity_codes = CommodityCode.all
  end

  def update
    @purchase_position = PurchasePosition.find(params[:id])
    @purchase_order = @purchase_position.purchase_order

    if @purchase_position.update_attributes(params[:purchase_position])
      redirect_to purchase_order_path(@purchase_order), notice: 'VK-Pos wurde erfolgreich gespeichert.'
    else
      render action: "edit"
    end
  end

end
