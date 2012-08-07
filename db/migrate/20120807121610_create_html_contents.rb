class CreateHtmlContents < ActiveRecord::Migration
  def change
    create_table :html_contents do |t|
      t.string :code
      t.integer :purchase_order_id
      t.integer :purchase_position_id
    end
  end
end
