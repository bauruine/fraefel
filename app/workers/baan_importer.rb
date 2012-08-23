class BaanImporter

  @queue = :baan_imports_queue

  def self.perform(unique_id, batch_range, import_type = "Versand")
  
    import_baan_import = Import::BaanImport.find(:unique_id => unique_id).first
    pending_workers = (import_baan_import.pending_workers.to_i - 1).to_s
    
    case import_type
    when "Versand"
      BaanRawData.where(:baan_import_id => batch_range).each do |baan_raw_data|
        Category.create_from_raw_data(baan_raw_data)
        Address.create_from_raw_data(baan_raw_data)
        Customer.create_from_raw_data(baan_raw_data)
        ZipLocation.create_from_raw_data(baan_raw_data)
        CommodityCode.create_from_raw_data(baan_raw_data)
        ShippingRoute.create_from_raw_data(baan_raw_data)
        PurchaseOrder.create_from_raw_data(baan_raw_data)
        PurchasePosition.create_from_raw_data(baan_raw_data)
      end
      
      import_baan_import.update(:pending_workers => pending_workers)
      
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
