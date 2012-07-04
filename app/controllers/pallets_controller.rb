class PalletsController < ApplicationController
  filter_access_to :all
  # before_filter :valid_for_assignment?, :only => :assign_positions
  # before_filter :valid_for_deletion?, :only => :remove_positions
  
  def show
    @pallet = Pallet.find(params[:id])
    respond_to do |format|
      format.pdf do
        render( 
          :pdf => "Palette-NR: #{@pallet.id}-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8',
          :header => {
            :right => "#{Time.now}",
            :line => true,
            :spacing => 2
          }
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
    @pallets = Pallet.where(:delivered => false).where("purchase_positions.id IS NOT NULL").includes(:cargo_list, [:purchase_positions => :commodity_code], [:purchase_orders => :shipping_address], :pallet_type)
    #@purchase_orders = PurchaseOrder.joins(:pallets)
    
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
    #@purchase_order = @pallet.purchase_order
    #@purchase_positions = @purchase_order.purchase_positions.where("pallet_id IS NULL")
    if request.xhr?
      render :template => 'pallets/ajax_edit'
    end
  end
  
  def update
    @pallet = Pallet.find(params[:id])
    if @pallet.update_attributes(params[:pallet])
      if params[:purchase_position_ids].present?
        @pallet.purchase_positions << PurchasePosition.find(params[:purchase_position_ids])
      end
      redirect_to(:back)
    else
      render 'edit'
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
    @pallet.purchase_positions -= @purchase_positions
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
    @purchase_order.create_calculation unless @purchase_order.calculation.present?
    if params[:pallet_id].present?
      @pallet = Pallet.where(:id => params[:pallet_id]).first
    else
      @pallet = Pallet.create
    end
    
    @pallet.purchase_positions += PurchasePosition.where(:id => params[:purchase_position_ids])
    @purchase_order.pallets += [@pallet]
    @purchase_order.calculation.update_attribute(:total_pallets, @purchase_order.pallets.count)
    
    params[:quantity_with_ids].each do |k, v|
      purchase_position = PurchasePosition.find(k.to_i)
      pallet_purchase_position_assignment = PalletPurchasePositionAssignment.where(:pallet_id => @pallet.id, :purchase_position_id => purchase_position.id).first
      pallet_purchase_position_assignment.update_attributes(:value_discount => (pallet_purchase_position_assignment.purchase_position.value_discount * v.to_i), :net_price => (pallet_purchase_position_assignment.purchase_position.net_price * v.to_i), :gross_price => (pallet_purchase_position_assignment.purchase_position.gross_price * v.to_i), :quantity => v.to_i, :amount => (pallet_purchase_position_assignment.purchase_position.amount * v.to_i), :weight => (pallet_purchase_position_assignment.purchase_position.weight_single * v.to_i)) if pallet_purchase_position_assignment.present?
    end
    redirect_to(:back)
  end
  
  private
  
  def valid_for_deletion?
    unless params[:purchase_position_ids].present?
      render "pallets/valid_for_deletion", :status => 400
    end
  end
  
  def valid_for_assignment?
    unless (params[:quantity_with_ids].present? && params[:purchase_position_ids].present? && params[:purchase_order_id].present?)
      render "pallets/valid_for_assignment", :status => 400
    end
  end
end
