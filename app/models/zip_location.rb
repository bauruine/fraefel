class ZipLocation < ActiveRecord::Base
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "zip_location_id"
  
  validates_uniqueness_of :title

  after_create :update_import_zip_location
  
  def self.create_from_raw_data(arg)
    zip_location_attributes = Hash.new

    zip_location_attributes.merge!(:title => arg.attributes["baan_35"])

    zip_location = ZipLocation.find_or_create_by_title(zip_location_attributes)
  end
  
  protected
  
  def update_import_zip_location
    import_zip_location = Import::ZipLocation.find(:baan_id => self.title).first
    unless import_zip_location.nil?
      import_zip_location.update(:mapper_id => self.id.to_s)
    end
  end
end
