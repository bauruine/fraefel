class Import::BaanWorker < Ohm::Model

  attribute :unique_id
  attribute :baan_import_id
  attribute :active
  
  index :unique_id
  index :baan_import_id
  index :active
  
  def self.destroy_all
    self.all.each do |baan_worker|
      baan_worker.delete
    end
  end
  
end
