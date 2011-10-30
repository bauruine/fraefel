class CreateBaanImports < ActiveRecord::Migration
  def self.up
    create_table :baan_imports do |t|
      t.integer :baan_import_group_id
      t.date :importing_date

      t.timestamps
    end
  end

  def self.down
    drop_table :baan_imports
  end
end
