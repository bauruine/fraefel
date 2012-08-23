class BaanImportsController < ApplicationController
  filter_access_to :all
  
  def index
    @baan_imports = BaanImport.order("id DESC")
  end
  
  def new
    @baan_import = BaanImport.new
    respond_to do |format|
      format.xml
      format.html
    end
  end
  
  def create
    @baan_import = BaanImport.new(params[:baan_import])
    if @baan_import.save
      redirect_to(baan_imports_url)
    else
      render 'new'
    end
  end
  
  def edit
    @baan_import = BaanImport.find(params[:baan_import])
  end
  
  def update
    @baan_import = BaanImport.find(params[:baan_import])
    if @baan_import.update_attributes(params[:baan_import])
      redirect_to :back
    else
      render 'edit'
    end
  end
  
  def import
    @baan_import = BaanImport.find(params[:id])
    BaanDelegator.perform_async(@baan_import.id)
    redirect_to(baan_imports_url)
  end
end
