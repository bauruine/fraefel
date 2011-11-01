class BaanImportsController < ApplicationController
  def index
    @baan_imports = BaanImport.all
  end
  
  def new
    @baan_import = BaanImport.new
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
    #file_to_import = @baan_import.baan_upload.path
    
    Customer.import(@baan_import)
    ShippingAddress.import(@baan_import)
    CommodityCode.import(@baan_import)
    ShippingRoute.import(@baan_import)
    PurchaseOrder.import(@baan_import)
    PurchasePosition.import(@baan_import)
    
    redirect_to(baan_imports_url)
  end
end
