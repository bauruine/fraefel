class BaanImporter
  @queue = :baan_imports_queue
  def self.perform(baan_import_id)
    baan_import = BaanImport.find(baan_import_id)
    case baan_import.baan_import_group.title
    when "Versand"
      Customer.import(baan_import)
      ShippingAddress.import(baan_import)
      CommodityCode.import(baan_import)
      ShippingRoute.import(baan_import)
      PurchaseOrder.import(baan_import)
      PurchasePosition.import(baan_import)
    when "Inventar-Baan-Artikel"
      Article.import(baan_import)
    when "Inventar-Lager-Adresse"
      Depot.import(baan_import)
    when "Inventar-Lager-Zone"
      Article.import_extras(baan_import)
    else
      #do something expceted
    end
  end
end