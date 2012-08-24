class BaanDelegator

  include Sidekiq::Worker
  
  sidekiq_options queue: "baan_delegator_queue"
  sidekiq_options retry: false
  
  def perform(baan_import_id)
  
    baan_import_id = baan_import_id.to_i
    start_time = Time.now
    
    # INFO: Delte old purchase_order_ids in Redis store
    Redis.connect.del("purchase_order_ids")
    
    # INFO: Create new Import::BaanImport instance with unique_id
    import_baan_import = Import::BaanImport.create(:unique_id => Time.now.to_s.to_md5)
    
    # INFO: Import CSV data in to db
    # TODO: Replace DB with REDIS Store
    BaanRawData.import(baan_import_id)
    
    # INFO: Start BaanImporter worker for each batch
    BaanRawData.find_in_batches(:conditions => {:baan_import_id => baan_import_id}, :batch_size => 200) do |batch_data|
      import_baan_worker = Import::BaanWorker.create(:active => "true", :baan_import_id => import_baan_import.unique_id, :unique_id => (Random.rand(1337) * Random.rand(1337) * Random.rand(1337) * Time.now.to_i).to_s.to_md5)
      BaanImporter.perform_async(import_baan_worker.unique_id, batch_data.first.id, batch_data.last.id, "Versand")
    end
    
    # INFO: BaanDelegator worker should sleep until each BaanImporter worker did his job
    while Import::BaanWorker.find(:active => "true", :baan_import_id => import_baan_import.unique_id).size != 0
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
    
    # INFO: Calculate time to complete patching
    puts "BaanImport Nr.: #{baan_import_id} finished patching... Time to complete => #{(Time.now - start_time) / 60} minutes."

  end


end
