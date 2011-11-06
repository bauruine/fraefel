class BaanImporter
  @queue = :baan_imports_queue
  def self.perform(baan_import_id)
    baan_import = BaanImport.find(baan_import_id)
    
    Customer.import(baan_import)
    ShippingAddress.import(baan_import)
    CommodityCode.import(baan_import)
    ShippingRoute.import(baan_import)
    PurchaseOrder.import(baan_import)
    PurchasePosition.import(baan_import)
  end
end