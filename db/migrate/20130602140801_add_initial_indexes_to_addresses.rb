class AddInitialIndexesToAddresses < ActiveRecord::Migration
  def change
    add_index :addresses, :customer_id
    add_index :addresses, :country
    add_index :addresses, :category_id
    add_index :addresses, :company_name
    add_index :addresses, :code
    add_index :addresses, :eori
  end
end
