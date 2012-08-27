class BaanJaintor
  
  include Sidekiq::Worker
  
  sidekiq_options queue: "baan_jaintor_queue"
  sidekiq_options retry: false

  def perform(unique_id, batch_from, batch_to, import_type = "Versand-Storniert")
    
    import_baan_worker = Import::BaanWorker.find(:unique_id => unique_id).first
    
    BaanRawData.where(:id => batch_from.to_i..batch_to.to_i).each do |baan_raw_data|
      PurchasePosition.jaintor_from_raw_data(baan_raw_data)
    end
    
    import_baan_worker.update(:active => "false")
    
  end
  
end
