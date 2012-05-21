class CreatePdfReports < ActiveRecord::Migration
  def self.up
    create_table :pdf_reports do |t|
      t.string :type
      t.integer :user_id
      t.string :searched_for
      t.string :report_file_name
      t.string :report_file_path
      t.boolean :saved_local

      t.timestamps
    end
  end

  def self.down
    drop_table :pdf_reports
  end
end
