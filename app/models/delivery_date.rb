class DeliveryDate < ActiveRecord::Base
  belongs_to :dateable, :polymorphic => true
end
