class BaanImporter
  
  include Sidekiq::Worker
  
  sidekiq_options queue: "baan_importer_queue"
  sidekiq_options retry: false

  def perform(unique_id, batch_from, batch_to, import_type = "Versand")
    import_baan_worker = Import::BaanWorker.find(:unique_id => unique_id).first
    
    case import_type
    when "Versand"
      BaanRawData.where(:id => batch_from.to_i..batch_to.to_i).each do |baan_raw_data|
        Category.create_from_raw_data(baan_raw_data)
        Address.create_from_raw_data(baan_raw_data)
        Customer.create_from_raw_data(baan_raw_data)
        ZipLocation.create_from_raw_data(baan_raw_data)
        CommodityCode.create_from_raw_data(baan_raw_data)
        ShippingRoute.create_from_raw_data(baan_raw_data)
        PurchaseOrder.create_from_raw_data(baan_raw_data)
        PurchasePosition.create_from_raw_data(baan_raw_data)
      end
      
      import_baan_worker.update(:active => "false")
      
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
