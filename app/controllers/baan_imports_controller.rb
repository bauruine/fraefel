class BaanImportsController < ApplicationController
  def index
    @baan_imports = BaanImport.all
  end
  
  def new
    @baan_import = BaanImport.new
  end
  
  def create
    @baan_import = BaanImport.new
    if @baan_import.save(params[:baan_import])
      redirect_to :back
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
end
