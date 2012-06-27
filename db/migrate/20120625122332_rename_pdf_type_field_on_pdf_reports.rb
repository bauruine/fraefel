class RenamePdfTypeFieldOnPdfReports < ActiveRecord::Migration
  def self.up
    rename_column :pdf_reports, :type, :pdf_type
  end

  def self.down
    rename_column :pdf_reports, :pdf_type, :pdf_type
  end
end