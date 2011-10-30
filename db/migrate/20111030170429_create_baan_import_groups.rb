class CreateBaanImportGroups < ActiveRecord::Migration
  def self.up
    create_table :baan_import_groups do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :baan_import_groups
  end
end
