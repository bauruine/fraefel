class CommodityCode < ActiveRecord::Base
  validates_uniqueness_of :code
  
end
