class BaanImport < ActiveRecord::Base
  has_attached_file :baan_upload
  
  belongs_to :baan_import_group, :class_name => "BaanImportGroup", :foreign_key => "baan_import_group_id"
  
  attr_accessible :baan_upload
  
  validates_attachment_presence :baan_upload
end
