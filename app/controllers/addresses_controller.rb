# encoding: utf-8
class AddressesController < FraefelController
  def index
    @search = PurchaseOrder.includes(:purchase_positions, :shipping_route, :calculation, :addresses).search(params[:search] || {:delivered_equals => "false"})
    @purchase_orders = @search.relation.ordered_for_delivery
    @addresses = Address.includes(:purchase_orders).where("addresses.category_id" => params[:category_id], "purchase_orders.id" => @purchase_orders.collect(&:id)).order("addresses.company_name ASC")

    respond_to do |format|
      format.json
    end
  end

end
