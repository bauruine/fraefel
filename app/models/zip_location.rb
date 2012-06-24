class ZipLocation < ActiveRecord::Base
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "zip_location_id"
  
  validates_uniqueness_of :title
end
