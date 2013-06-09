class ZipLocation < ActiveRecord::Base
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "zip_location_id"

  validates_uniqueness_of :title

  after_create :update_import_zip_location

  def self.create_from_raw_data(arg)
    zip_location_attributes = Hash.new

    zip_location_attributes.merge!(:title => arg.attributes["baan_35"])

    zip_location = ZipLocation.where(:title => zip_location_attributes[:title]).first
    zip_location ||= ZipLocation.new(zip_location_attributes)

    if zip_location.new_record?
      zip_location.save
    else
      zip_location.attributes = zip_location_attributes
      if zip_location.changed?
        zip_location.save
      end
    end
  end

  protected

  def update_import_zip_location
    import_zip_location = Import::ZipLocation.find(:baan_id => self.title).first
    unless import_zip_location.nil?
      import_zip_location.update(:mapper_id => self.id.to_s)
    end
  end
end
