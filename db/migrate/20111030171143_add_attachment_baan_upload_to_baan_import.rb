class AddAttachmentBaanUploadToBaanImport < ActiveRecord::Migration
  def self.up
    add_column :baan_imports, :baan_upload_file_name, :string
    add_column :baan_imports, :baan_upload_content_type, :string
    add_column :baan_imports, :baan_upload_file_size, :integer
    add_column :baan_imports, :baan_upload_updated_at, :datetime
  end

  def self.down
    remove_column :baan_imports, :baan_upload_file_name
    remove_column :baan_imports, :baan_upload_content_type
    remove_column :baan_imports, :baan_upload_file_size
    remove_column :baan_imports, :baan_upload_updated_at
  end
end
