class CreateMicrosoftDatabaseTypes < ActiveRecord::Migration
  def self.up
    create_table :microsoft_database_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :microsoft_database_types
  end
end
