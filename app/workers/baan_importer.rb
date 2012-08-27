class BaanImporter
  
  include Sidekiq::Worker
  
  sidekiq_options queue: "baan_importer_queue"
  sidekiq_options retry: false

  def perform(unique_id, batch_from, batch_to, import_type = "Versand")
  
    import_baan_worker = Import::BaanWorker.find(:unique_id => unique_id).first
    
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
    
  end
  
end
