class PurchaseOrdersController < ApplicationController
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_positions = @purchase_order.purchase_positions.where('pallet_id IS NULL')
  end

  def index
  end

end
