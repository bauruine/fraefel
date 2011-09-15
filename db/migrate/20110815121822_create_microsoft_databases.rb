class CreateMicrosoftDatabases < ActiveRecord::Migration
  def self.up
    create_table :microsoft_databases do |t|
      t.string :name
      t.integer :database_type_id
      t.string :file
      t.string :file_directory
      t.timestamps
    end
  end

  def self.down
    drop_table :microsoft_databases
  end
end
