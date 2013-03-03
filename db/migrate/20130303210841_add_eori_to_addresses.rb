class AddEoriToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :eori, :string
  end
end