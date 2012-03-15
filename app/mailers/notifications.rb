class Notifications < ActionMailer::Base
  default :from => "api.fraefel@gmail.com"

  def password_reset_instructions(user)
    @user = User.find(user)
    @edit_password_reset_url = edit_password_reset_url(@user.perishable_token)
    mail to: @user.email, from: "api.fraefel@gmail.com", subject: "Instruktionen zum setzen/wiederherstellen des Passwords"
  end
  
  def user_signed_up(user)
    @user = User.find(user)
    mail to: @user.email, from: "api.fraefel@gmail.com", subject: "Neuer Benutzer erfasst - #{@user.username}"
  end
  
end
