class HtmlContent < ActiveRecord::Base
  belongs_to :purchase_order
  belongs_to :purchase_position
  belongs_to :pallet
end
