#encoding: utf-8
class PasswordResetsController < ApplicationController
  skip_before_filter :require_user
  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]
  
  def new
    flash[:notice] = "Bitte Benutzername oder Email eingeben um fortzufahren."
  end

  def create
    @user = User.where("username = '#{params[:username]}' or email = '#{params[:email]}'")
    respond_to do |format|
      if @user.present?
        @user.first.deliver_password_reset_instructions!
        format.html { redirect_to login_path, :notice => "Die Instruktionen wurden per Email versendet. Achtung! Link ist maximal 5 Stunden gültig." }
      else
        format.html do
          flash[:error] = "Mit den eingegebenen Daten konnte kein Benutzer gefunden werden. Daten überprüfen und nochmals versuchen."
          render "new"
        end
      end
    end
    
  end

  def edit
    flash[:notice] = "Bitte neues Passwort setzten. Wird das Formular leer abgesendet wird der Vorgang abgebrochen."
  end

  def update
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    #@user.save_without_session_maintenance
    
    if @user.save_without_session_maintenance
      flash[:notice] = "Neues Password wurde erfolgreich gesetzt"
      redirect_to login_path
    else
      flash.now[:error] = "Password konnte nicht gesetzt werden. Bitte anderes Passwort wählen."
      render 'edit'
    end
  end
  
  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = "Der Passwort-Zurücksetzungsvorgang wurde wegen inaktivität deaktiviert. Um neuen Vorgang zu starten bitte auf Zurücksetzen klicken."
      redirect_to login_url
    end
  end
end
