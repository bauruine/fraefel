class BaanImporter
  @queue = :baan_imports_queue
  def self.perform(baan_import_id)
    baan_import = BaanImport.find(baan_import_id)
    case baan_import.baan_import_group.title
    when "Versand"
      BaanRawData.import(baan_import_id)
      Address.import(baan_import_id)
      Customer.import(baan_import_id)
      ShippingAddress.import(baan_import_id)
      CommodityCode.import(baan_import_id)
      ShippingRoute.import(baan_import_id)
      PurchaseOrder.import(baan_import_id)
      PurchasePosition.import(baan_import_id)
      BaanRawData.patch_import(baan_import_id)
      #PurchaseOrder.patch_calculation
      #PurchaseOrder.patch_aggregations
    when "Inventar-Baan-Artikel"
      Article.import(baan_import)
    when "Inventar-Lager-Adresse"
      Depot.import(baan_import)
    when "Inventar-Lager-Zone"
      Article.import_extras(baan_import)
    when "Inventar-Baan-Artikel-Gruppe"
      ArticleGroup.import(baan_import)
    when "Inventar-Baan-Artikel-Preis-Gruppe"
      Article.import_extras_1(baan_import)
    when "Inventar-BaanCSV"
      Article.import_baan_file(baan_import)
    when "Versand-Verrechnet"
      BaanRawData.import(baan_import_id)
      PurchasePosition.clean_up_delivered(baan_import_id)
      BaanRawData.patch_import(baan_import_id)
    else
      #do something expceted
    end
  end
end