class AddOrderDataToArticlePositionTimeShiftingAssignments < ActiveRecord::Migration
  def self.up
    add_column :article_position_time_shifting_assignments, :order_number, :string
    add_column :article_position_time_shifting_assignments, :confirmed_date, :date
    add_column :article_position_time_shifting_assignments, :purchase_positions_collection, :string
  end

  def self.down
    remove_column :article_position_time_shifting_assignments, :purchase_positions_collection
    remove_column :article_position_time_shifting_assignments, :confirmed_date
    remove_column :article_position_time_shifting_assignments, :order_number
  end
end