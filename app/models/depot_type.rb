class DepotType < ActiveRecord::Base
  has_many :depots, :class_name => "depot", :foreign_key => "depot_type_id"
end
