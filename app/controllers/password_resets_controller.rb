class PasswordResetsController < ApplicationController
  skip_before_filter :require_user
  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
  
  def new
    flash[:notice] = "Bitte Benutzername und Email eingeben um fortzufahren."
  end

  def create
    @user = User.find_by_email(params[:email])
    respond_to do |format|
      if @user
        @user.deliver_password_reset_instructions!
        format.html { redirect_to root_path, notice: 'Die Instruktionen wurden per Email versendet.' }
      else
        format.html { render action: "new" }
      end
    end
    
  end

  def edit
  end

  def update
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.save_without_session_maintenance
    
    if @user.save
      flash[:success] = "Password wurde erfolgreich gesetzt"
      redirect_to root_path
    else
      render 'edit'
    end
  end
  
  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = "Benutzer wurde nicht gefunden."
      redirect_to root_url
    end
  end
end
