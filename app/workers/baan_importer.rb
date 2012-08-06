class BaanImporter
  @queue = :baan_imports_queue
  def self.perform(baan_import_id)
    baan_import = BaanImport.find(baan_import_id)
    case baan_import.baan_import_group.title
    when "Versand"
      BaanRawData.import(baan_import_id)
      BaanRawData.where(:baan_import_id => baan_import.id).each do |baan_raw_data|
        Address.create_from_raw_data(baan_raw_data)
        Customer.create_from_raw_data(baan_raw_data)
        ZipLocation.create_from_raw_data(baan_raw_data)
        CommodityCode.create_from_raw_data(baan_raw_data)
        ShippingRoute.create_from_raw_data(baan_raw_data)
        PurchaseOrder.create_from_raw_data(baan_raw_data)
        PurchasePosition.create_from_raw_data(baan_raw_data)
      end
      ###BaanRawData.patch_import(baan_import_id)
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
      PurchaseOrder.clean_up_delivered
      BaanRawData.patch_import(baan_import_id)
    when "Versand-Storniert"
      BaanRawData.import_cancelled(baan_import_id)
      BaanRawData.patch_import(baan_import_id)
    else
      #do something expceted
    end
  end
end
