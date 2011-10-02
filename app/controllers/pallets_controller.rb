class PalletsController < ApplicationController
  
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
            :left => "Fraefel AG",
            :right => "#{Time.now}",
            :line => true,
            :spacing => 2
          },
          :footer => {
            :left => "#{pallet_url(@pallet, :format => :pdf)}",
            :right => "Seite [page]",
            :line => true
          }
        )
      end
    end
  end
  
  def index
    @pallets = Pallet.where(:delivered => false)
    @purchase_orders = PurchaseOrder.joins(:pallets)
    
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
    @purchase_order = @pallet.purchase_order
    @purchase_positions = @purchase_order.purchase_positions.where("pallet_id IS NULL")
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
    @purchase_positions = PurchasePosition.find(params[:purchase_position_ids])
    @pallet.purchase_positions.delete(@purchase_positions)
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
    if params[:pallet_id].present?
      @pallet = Pallet.find(params[:pallet_id])
      @pallet.purchase_positions << PurchasePosition.find(params[:purchase_position_ids])
    else
      @purchase_order = PurchaseOrder.find(params[:purchase_order_id])
      @pallet = @purchase_order.pallets.build
      @pallet.purchase_positions << PurchasePosition.find(params[:purchase_position_ids])
      @pallet.save
    end
    redirect_to(:back)
  end
  
end
