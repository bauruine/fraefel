class AddCategoryIdToHtmlContents < ActiveRecord::Migration
  def change
    add_column :html_contents, :category_id, :integer
  end
end
