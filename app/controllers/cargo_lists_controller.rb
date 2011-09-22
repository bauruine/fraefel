class CargoListsController < ApplicationController
  
  def show
    @cargo_list = CargoList.find(params[:id])
    @assigned_pallets = @cargo_list.pallets
    
    @pallets = Pallet.order("purchase_positions.delivery_date asc").includes(:purchase_order => [:purchase_positions]) - @assigned_pallets - Pallet.where("cargo_list_id IS NOT NULL")
  end
  
  def index
    @cargo_lists = CargoList.find(:all)
  end
  
  def new
    @cargo_list = CargoList.new
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
    @cargo_list.pallets = @pallets
    
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
end
