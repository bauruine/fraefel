class HtmlContent < ActiveRecord::Base
  
  belongs_to :purchase_order
  belongs_to :purchase_position
  

end
