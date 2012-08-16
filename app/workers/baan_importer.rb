class BaanImporter
  @queue = :baan_imports_queue
  def self.perform(baan_import_id)
    baan_import = BaanImport.find(baan_import_id)
    @start_time = Time.now
    case baan_import.baan_import_group.title
    when "Versand"
      Redis.connect.del("purchase_order_ids")
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
      PurchaseOrder.where(:id => Redis.connect.smembers("purchase_order_ids").collect{|v| v.to_i}.uniq).each do |purchase_order|
        # Updating considered PurchaseOrder instances
        purchase_order.patch_calculation
        purchase_order.patch_aggregations
      end
      puts "Time to complete -- #{Time.now - @start_time}"
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
      BaanRawData.where(:baan_import_id => baan_import.id).each do |baan_raw_data|
        PurchasePosition.update_from_raw_data(baan_raw_data)
      end
      PurchaseOrder.where(:baan_id => BaanRawData.where(:baan_import_id => baan_import.id).collect(&:baan_2)).each do |purchase_order|
        purchase_order.patch_picked_up
        purchase_order.patch_calculation
        purchase_order.patch_aggregations
      end
    when "Versand-Storniert"
      BaanRawData.import_cancelled(baan_import_id)
    else
      #do something expceted
    end
  end
end
