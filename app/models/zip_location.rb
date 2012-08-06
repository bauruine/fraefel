class ZipLocation < ActiveRecord::Base
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "zip_location_id"
  
  validates_uniqueness_of :title

  
  def self.create_from_raw_data(arg)
    zip_location_attributes = Hash.new

    zip_location_attributes.merge!(:title => arg.attributes["baan_35"])

    zip_location = ZipLocation.find_or_create_by_title(zip_location_attributes)
  end

end
