class PurchaseOrdersController < ApplicationController
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_positions = @purchase_order.purchase_positions.where('pallet_id IS NULL')
  end

  def index
    @purchase_orders = PurchaseOrder.where(:status => "open").where("customer_id IS NOT NULL").order("purchase_positions.delivery_date asc, delivery_route asc, customer_id asc").includes(:purchase_positions)
  end

end
