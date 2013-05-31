class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  attr_accessor :is_importing
  
  has_many :user_role_assignments
  has_many :roles, :through => :user_role_assignments
  
  has_many :department_user_assignments
  has_many :departments, :class_name => "Department", :through => :department_user_assignments
  
  has_many :pdf_reports, :class_name => "PdfReport"
  
  validates_presence_of :roles, :forename, :surname, :email
  
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
