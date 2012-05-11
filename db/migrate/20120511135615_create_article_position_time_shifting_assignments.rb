class CreateArticlePositionTimeShiftingAssignments < ActiveRecord::Migration
  def self.up
    create_table :article_position_time_shifting_assignments do |t|
      t.integer :article_position_id
      t.integer :time_shifting_id
      
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :article_position_time_shifting_assignments
  end
end
