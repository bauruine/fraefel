class BaanImportsController < ApplicationController
  def index
    @baan_imports = BaanImport.all
  end
  
  def new
    @baan_import = BaanImport.new
  end
  
  def create
    @baan_import = BaanImport.new
    baan_import_params = params[:baan_import]
    baan_import_params[:baan_upload_content_type] = baan_import_params[:baan_upload].content_type
    if @baan_import.save(baan_import_params)
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
