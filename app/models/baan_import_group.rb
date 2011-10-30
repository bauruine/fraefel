class BaanImportGroup < ActiveRecord::Base
  has_many :baan_imports, :class_name => "BaanImport", :foreign_key => "baan_group_id"
end
