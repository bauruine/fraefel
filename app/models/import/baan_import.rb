class Import::BaanImport < Ohm::Model

  attribute :unique_id
  attribute :baan_import_id
  attribute :pending_workers
  
  index :unique_id
  index :baan_import_id
  
  def self.destroy_all
    self.all.each do |baan_import|
      baan_import.delete
    end
  end
  
end
