class PalletsController < ApplicationController
  filter_access_to :all

  def show
    @pallet = Pallet.find(params[:id])
    @purchase_positions = @pallet.purchase_positions.includes(:shipping_address)
    respond_to do |format|
      format.pdf do
        render(
          :pdf => "Palette-NR: #{@pallet.id}-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :print_media_type => true,
          :orientation => 'Landscape',
          :encoding => 'UTF-8'
        )
      end
    end
  end

  def ajax_show
    @pallet = Pallet.find(params[:id])
  end

  def search_for
    @pallet = Pallet.where(:id => params[:pallet_id])
  end

  def index
    @search = Pallet.where("pallets.line_items_quantity != 0").includes(:zip_location, :shipping_address, :cargo_list, {:pallet_purchase_position_assignments => {:purchase_position => [:commodity_code, :html_content]}}, :pallet_type).search(params[:q] || {:delivered_eq => "false"})
    @pallets = @search.result

    @pallet_ids = @pallets.collect(&:id)

    @level_3 = Address.order("addresses.company_name ASC").select("DISTINCT `addresses`.*").where("addresses.category_id = ?", 10).where("pallets.id" => @pallet_ids).joins(:pallets)

    respond_to do |format|
      format.html
      format.pdf do
        render(
          :pdf => "Paletten-Liste-#{Time.now}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8',
          :header => {
            :left => "Fraefel AG",
            :right => "#{Date.today}",
            :line => true,
            :spacing => 2
          },
          :footer => {
            :left => "#{pallets_url()}",
            :right => "Seite [page]",
            :line => true
          }
        )
      end
    end
  end

  def edit
    @pallet = Pallet.find(params[:id])
    respond_to do |format|
      format.html
      format.xml
    end
  end

  def update
    @pallet = Pallet.find(params[:id])
    respond_to do |format|
      if @pallet.update_attributes(params[:pallet])
        if params[:purchase_position_ids].present?
          @pallet.purchase_positions << PurchasePosition.find(params[:purchase_position_ids])
        end
        format.html { redirect_to(:back) }
        format.js
      else
        format.html { render action: "edit" }
        format.js
      end
    end
  end

  def create
    @purchase_order = PurchaseOrder.find(params[:purchase_order])
    @pallet = @purchase_order.pallets.build()
    if @pallet.save
      redirect_to(:back)
    else
      flash[:error] = "Could not create a new pallet for this order..."
    end
  end

  def remove_positions
    @pallet = Pallet.find(params[:id])
    @purchase_positions = PurchasePosition.where(:id => params[:purchase_position_ids])
    @purchase_order = @purchase_positions.first.purchase_order

    PalletPurchasePositionAssignment.where(:pallet_id => @pallet.id, :purchase_position_id => params[:purchase_position_ids]).destroy_all

    if !Pallet.find(@pallet).purchase_positions.where(:purchase_order_id => @purchase_positions.first.purchase_order_id).present?
      # remove purchase_order assignment from table
      @pallet.purchase_orders -= [@purchase_positions.first.purchase_order]
      @purchase_order.calculation.update_attribute(:total_pallets, @purchase_order.pallets.count)
    end
    redirect_to(:back)
  end

  def delete_empty
    @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
    @purchase_order.pallets.each do |pallet|
      if !pallet.purchase_positions.present?
        pallet.destroy
      end
    end
    redirect_to(:back)
  end

  def assign_positions
    @purchase_order = PurchaseOrder.where(:id => params[:purchase_order_id]).first
    if params[:pallet_id].present?
      @pallet = Pallet.where(:id => params[:pallet_id]).first
    else
      @pallet = Pallet.create
    end

    if params[:purchase_position_ids].present?
      @purchase_order.pallets += [@pallet]
    end

    pallet_purchase_position_assignment_attributes = {}
    params[:quantity_with_ids].each do |k, v|
      if params[:purchase_position_ids].present? && params[:purchase_position_ids].include?(k)
        purchase_position = PurchasePosition.find(k.to_i)
        pallet_purchase_position_assignment_attributes.merge!(:purchase_position_id => purchase_position.id)
        pallet_purchase_position_assignment_attributes.merge!(:value_discount => purchase_position.value_discount * v.to_i)
        pallet_purchase_position_assignment_attributes.merge!(:net_price => purchase_position.net_price * v.to_i)
        pallet_purchase_position_assignment_attributes.merge!(:gross_price => purchase_position.gross_price * v.to_i)
        pallet_purchase_position_assignment_attributes.merge!(:quantity => v.to_i)
        pallet_purchase_position_assignment_attributes.merge!(:amount => purchase_position.amount * v.to_i)
        pallet_purchase_position_assignment_attributes.merge!(:weight => purchase_position.weight_single * v.to_i)

        @pallet.pallet_purchase_position_assignments.create(pallet_purchase_position_assignment_attributes)
      end
    end
    redirect_to(:back)
  end

end
