class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.perishable_token_valid_for = 300.minutes
  end
  
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
  
  def self.current=(user)
    @current_user = user
  end
  
  def self.current
    @current_user
  end
  
  def full_name
    "#{self.forename} #{self.surname}"
  end
end
