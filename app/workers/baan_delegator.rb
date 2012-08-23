class BaanDelegator

  include Sidekiq::Worker
  
  sidekiq_options queue: "baan_delegator_queue"
  sidekiq_options retry: false
  
  def perform(baan_import_id)
  
    baan_import_id = baan_import_id.to_i
    unique_id = Time.now.to_s.to_md5
    start_time = Time.now
    
    # INFO: Delte old purchase_order_ids in Redis store
    Redis.connect.del("purchase_order_ids")
    
    # INFO: Create new Import::BaanImport instance with unique_id
    import_baan_import = Import::BaanImport.create(:unique_id => unique_id)
    
    # INFO: Import CSV data in to db
    # TODO: Replace DB with REDIS Store
    BaanRawData.import(baan_import_id)
    
    # INFO: Calculate how many workers we should start and update Import::BaanImport instance
    workers_total = (BaanRawData.where(:id => baan_import_id).count / 300) + 1
    import_baan_import.update(:pending_workers => workers_total.to_s)
    
    # INFO: Start BaanImporter worker for each batch
    BaanRawData.find_in_batches(:conditions => {:baan_import_id => baan_import_id}, :batch_size => 300) do |batch_data|
      BaanImporter.perform_async(unique_id, batch_data.first.id, batch_data.last.id, "Versand")
    end
    
    # INFO: BaanDelegator worker should sleep until each BaanImporter worker did his job
    while import_baan_import.pending_workers != "0"
      sleep 5.seconds
    end
    
    # INFO: Calculate time to complete import and reset start_time
    puts "BaanImport Nr.: #{baan_import_id} finished importing... Time to complete => #{(Time.now - start_time) / 60} minutes."
    start_time = Time.now
    
    # INFO: Patch considered purchase_orders
    PurchaseOrder.where(:id => Redis.connect.smembers("purchase_order_ids").collect{|v| v.to_i}.uniq).each do |purchase_order|
      
      # INFO-1: Change picked_up && delivered if new child
      purchase_order.patch_picked_up
      purchase_order.patch_delivered
      # END INFO-1
      
      purchase_order.patch_calculation
      purchase_order.patch_aggregations
    end
    
    # INFO: Calculate time to complete patching and destroy Import::BaanImport instance
    puts "BaanImport Nr.: #{baan_import_id} finished patching... Time to complete => #{(Time.now - start_time) / 60} minutes."
    import_baan_import.delete
  end


end
