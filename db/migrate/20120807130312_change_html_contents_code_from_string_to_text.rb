class ChangeHtmlContentsCodeFromStringToText < ActiveRecord::Migration
  def up
    change_column :html_contents, :code, :text
  end

  def down
    change_column :html_contents, :code, :string
  end
end
