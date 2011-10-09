class CargoListsController < ApplicationController
  
  def show
    @cargo_list = CargoList.find(params[:id])
    @assigned_pallets = @cargo_list.pallets
    @pallets_count = @cargo_list.pallets.sum("count_as", :include => [:pallet_type])
    @pallets = Pallet.order("purchase_positions.delivery_date asc").includes(:purchase_order => [:purchase_positions]) - @assigned_pallets - Pallet.where("cargo_list_id IS NOT NULL")
  end
  
  def index
    if params[:search].present? && params[:search][:delivered_equals].present? && params[:search][:delivered_equals] == "true"
      @search = CargoList.search(params[:search])
    else
      @search = CargoList.where(:delivered => false).search(params[:search])
    end
    @cargo_lists = @search
  end
  
  def new
    @cargo_list = CargoList.new
    #@customers = Customer.where("pallets.id IS NOT NULL").includes(:purchase_orders => [:pallets])
  end
  
  def create
    @cargo_list = CargoList.new(params[:cargo_list])
    if @cargo_list.save
      redirect_to(cargo_list_url(@cargo_list))
    else
      render 'new'
    end
  end
  
  def edit
    @cargo_list = CargoList.find(params[:id])
  end
  
  def update
    @cargo_list = CargoList.find(params[:id])
    if @cargo_list.update_attributes(params[:cargo_list])
      redirect_to(cargo_list_url(@cargo_list))
    else
      render 'edit'
    end
  end
  
  def destroy
    @cargo_list = CargoList.find(params[:id]).destroy
    redirect_to(cargo_lists_url)
  end
  
  def assign_pallets
    @pallets = Pallet.find(params[:pallet_ids])
    @cargo_list = CargoList.find(params[:cargo_id])
    @cargo_list.pallets += @pallets
    
    redirect_to(:back)
  end
  
  def remove_pallets
    @pallets = Pallet.find(params[:pallet_ids])
    @cargo_list = CargoList.find(params[:cargo_id])
    @cargo_list.pallets -= @pallets
    
    redirect_to(:back)
  end
  
  def print_pallets
    @cargo_list = CargoList.find(params[:id])
    @pallets = @cargo_list.pallets
    
    respond_to do |format|
      format.pdf do
        render( 
          :pdf => "file_name",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :header => {
            :left => "Fraefel AG",
            :right => "Ladeliste NR #{@cargo_list.id}",
            :line => true,
            :spacing => 2
          },
          :footer => {
            :left => "#{cargo_list_url(@cargo_list)}",
            :right => "Seite [page]",
            :line => true
          }
        )
      end
    end
  end
  
  def collective_invoice
    @cargo_list = CargoList.find(params[:id])
    #@customer = @cargo_list.referee
    #@customer_address = @customer.shipping_addresses.first
    @ordered_commodity_codes = PurchasePosition.sum("amount", :include => [:commodity_code, {:pallet => :cargo_list}], :group => "commodity_code", :conditions => {:cargo_lists => { :id => @cargo_list.id }})
    @purchase_positions_amount = PurchasePosition.calculate_for_invoice("total_amount", [@cargo_list.id])
    @pallets_additional_space = @cargo_list.pallets.sum("additional_space") / 120
    @pallets_weight = PurchasePosition.calculate_for_invoice("weight_total", [@cargo_list.id])
    @pallets_count = @cargo_list.pallets.sum("count_as", :include => [:pallet_type])
    @vat = ((@purchase_positions_amount / 100.to_f) * 19.to_f)
    @cargo_list.update_attributes(:vat => @vat)
    
    respond_to do |format|
      format.pdf do
        render( 
          :pdf => "Sammelrechnung_Versand-NR##{@cargo_list.id}-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8'
        )
      end
    end
  end
  
  def print_lebert
    @cargo_list = CargoList.find(params[:id])
    @customer = @cargo_list.referee
    #@customer_address = @customer.shipping_addresses.first
    
    respond_to do |format|
      format.pdf do
        render( 
          :pdf => "Angaben-Lebert_Versand-NR##{@cargo_list.id}-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8'
        )
      end
    end
    
  end
  
  def heydo
    PurchasePosition.sum("amount", :include => [:commodity_code, {:pallet => :cargo_list}], :group => "commodity_code", :conditions => {:cargo_lists => { :id => 2}})
  end
  
end
