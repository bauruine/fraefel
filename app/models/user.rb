class User < ActiveRecord::Base
  acts_as_authentic
  has_and_belongs_to_many :roles
  
  def role_symbols
    roles.map do |role|
      role.name.underscore.to_sym
    end
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifications.password_reset_instructions(self).deliver
  end
  
end
