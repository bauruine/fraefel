class AddPalletIdToHtmlContents < ActiveRecord::Migration
  def change
    add_column :html_contents, :pallet_id, :integer
  end
end
