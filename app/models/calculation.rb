class Calculation < ActiveRecord::Base
  belongs_to :calculable, :polymorphic => true
end
