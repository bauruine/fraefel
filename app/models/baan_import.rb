class BaanImport < ActiveRecord::Base
  has_attached_file :baan_upload, :path => ':rails_root/public/system/:attachment/:id/:filename', :processors => []
  belongs_to :baan_import_group, :class_name => "BaanImportGroup", :foreign_key => "baan_import_group_id"
end
