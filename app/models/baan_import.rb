class BaanImport < ActiveRecord::Base
  #has_attached_file :baan_upload, :url => ':rails_root/public/system/:attachment/:id/:filename', :path => ':rails_root/public/system/:attachment/:id/:filename'
  has_attached_file :baan_upload
  
  belongs_to :baan_import_group, :class_name => "BaanImportGroup", :foreign_key => "baan_import_group_id"
  
  attr_accessible :baan_upload
end
