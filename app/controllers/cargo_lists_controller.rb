# encoding: utf-8

class CargoListsController < FraefelController
  filter_access_to :all

  def show
    @cargo_list = CargoList.where(:id => params[:id]).first
    @pallets = @cargo_list.pallets.order("pallets.id DESC").includes(:pallet_type, [:purchase_orders => :shipping_route], [:purchase_positions => :zip_location])

    @available_pallets = Pallet.where("pallets.cargo_list_id" => nil, "pallets.delivery_rejection_id" => nil, "pallets.delivered" => false)
    @available_pallets = @available_pallets.where("pallets.line_items_quantity != 0")
    @available_pallets = @available_pallets.includes(:pallet_type, [:purchase_orders => :shipping_route], [:purchase_positions => :zip_location], :cargo_list)

    @purchase_positions = PurchasePosition.where("cargo_lists.id = ?", @cargo_list.id).includes(:pallets => :cargo_list)
    @pallet_types = PalletType.where("pallets.cargo_list_id" => @cargo_list.id).joins(:pallets)
    @pallet_purchase_position_assignments = PalletPurchasePositionAssignment.select("DISTINCT pallet_purchase_position_assignments.*").where("cargo_lists.id = ?", @cargo_list.id ).joins(:pallet => :cargo_list)

    @addresses = Address.select("DISTINCT addresses.*").where("cargo_lists.id" => @cargo_list.id, "addresses.category_id" => 10, "pallet_purchase_position_assignments.is_individual_package" => false).joins(:pallets => [:cargo_list, :line_items])
    @special_addresses = Address.select("DISTINCT addresses.*").where("cargo_lists.id" => @cargo_list.id, "addresses.category_id" => 10, "pallet_purchase_position_assignments.is_individual_package" => true).joins(:pallets => [:cargo_list, :line_items])
    @address = Address.where(:id => @cargo_list.level_3).first
    @address ||= @addresses.limit(1).first

    respond_to do |format|
      format.html
      format.pdf do
        render(
          :pdf => (params[:pdf_title].present? ? "#{params[:pdf_title]}" : "Kein Titel-#{Date.today}"),
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8',
          :footer => {
            :left => params[:pdf_type] != "invoice" ? "#{Time.now.to_formatted_s(:swiss_date)}" : "",
            :right => params[:pdf_type] != "invoice" ? "Seite [page] / [topage]" : "",
            :line => false
          }
        )
      end
    end

  end

  def search_for
    @cargo_list = CargoList.where(:id => params[:cargo_list_id])
    if @cargo_list.present?
      redirect_to cargo_list_url(@cargo_list.first)
    end
  end

  def index
    if params[:q].present? && params[:q][:delivered_eq].present? && params[:q][:delivered_eq] == "true"
      @search = CargoList.search(params[:q])
    else
      @search = CargoList.where(:delivered => false).search(params[:q])
    end
    @cargo_lists = @search.result
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
    @addresses = Address.select("DISTINCT `addresses`.*").where("cargo_lists.id" => @cargo_list.id).where("addresses.category_id" => 10).joins(:pallets => :cargo_list)
    respond_to do |format|
      format.html
    end
  end

  def update
    @cargo_list = CargoList.find(params[:id])
    respond_to do |format|
      if @cargo_list.update_attributes(params[:cargo_list])
        format.html { redirect_to @cargo_list, notice: 'Versand wurde erfolgreich gespeichert.' }
      else
        format.html { render action: "edit" }
      end
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
    @ordered_commodity_codes = PurchasePosition.sum("amount", :include => [:commodity_code, {:pallets => :cargo_list}], :group => "commodity_code", :conditions => {:cargo_lists => { :id => @cargo_list.id }})
    @purchase_positions_amount = PurchasePosition.calculate_for_invoice("amount", [@cargo_list.id])
    @pallets_additional_space = @cargo_list.pallets.sum("additional_space").to_f
    @pallets_weight = PurchasePosition.calculate_for_invoice("weight_total", [@cargo_list.id])
    @pallets_count = @cargo_list.pallets.sum("count_as", :include => [:pallet_type])

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
    @purchase_positions_group_consignee_full = PurchasePosition.where("cargo_lists.id = #{@cargo_list.id}").includes(:pallets => :cargo_list).group(:consignee_full)
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
          :encoding => 'UTF-8',
          :footer => {
            :left => Time.now,
            :right => "Seite [page] / [topage]",
            :line => true
          }
        )
      end
    end

  end

  def controll_invoice
    @cargo_list = CargoList.find(params[:id])
    @customer = @cargo_list.referee
    #@customer_address = @customer.shipping_addresses.first
    @grouped_commodity_codes_with_amount = PurchasePosition.sum("amount", :include => [:commodity_code, {:pallets => :cargo_list}], :group => "commodity_code", :conditions => {:cargo_lists => { :id => @cargo_list.id }})

    respond_to do |format|
      format.pdf do
        render(
          :pdf => "Kontrolle Versand##{@cargo_list.id}-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8'
        )
      end
    end

  end

  def recalculate
    @cargo_list = CargoList.find(params[:id])

    @cargo_list.pallets.each do |pallet|
      pallet.recalculate_line_items_weight_net_price_and_gross_price_and_value_discount
    end

    redirect_to(cargo_list_path(@cargo_list), notice: 'Versand wurde neu berechnet.')
  end

  def heydo
    PurchasePosition.sum("amount", :include => [:commodity_code, {:pallet => :cargo_list}], :group => "commodity_code", :conditions => {:cargo_lists => { :id => 2}})
  end

  private

  def calculate_cargo_list
    cargo_list = CargoList.find(params[:id])
    purchase_positions_amount = 0

    PurchasePosition.sum("amount", :include => [:commodity_code, {:pallets => :cargo_list}], :group => "commodity_code", :conditions => {:cargo_lists => { :id => cargo_list.id }}).each do |foo|
      purchase_positions_amount += foo[1]
    end
    vat = ((purchase_positions_amount / 100.to_f) * 19.to_f)
    effective_invoice_amount = purchase_positions_amount + vat
    cargo_list.update_attributes(:vat => vat, :total_amount => effective_invoice_amount, :effective_invoice_amount => effective_invoice_amount, :subtotal => purchase_positions_amount)

  end

end
