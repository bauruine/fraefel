class BaanImport < ActiveRecord::Base
  has_attached_file :baan_upload

  belongs_to :baan_import_group, :class_name => "BaanImportGroup", :foreign_key => "baan_import_group_id"
  has_many :baan_raw_data, :class_name => "BaanRawData", :foreign_key => "baan_import_id"

  attr_accessible :baan_upload, :baan_import_group_id

  validates_attachment_presence :baan_upload
  validates :baan_import_group_id, :presence => true
end
