class AddCodeToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :code, :string
  end

  def self.down
    remove_column :addresses, :code
  end
end
