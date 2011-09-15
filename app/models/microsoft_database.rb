class MicrosoftDatabase < ActiveRecord::Base
  #attr_accessible :name, :database_type_id, :file, :file_directory
  validates_presence_of :name, :database_type, :file
  belongs_to :database_type, :class_name => "MicrosoftDatabaseType", :foreign_key => "database_type_id"

end
