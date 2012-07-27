class UserSessionsController < ApplicationController
  skip_before_filter :require_user

  # GET /user_sessions/new
  # GET /user_sessions/new.xml
  def new
    @user_session = UserSession.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /user_sessions
  # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if params[:user_session][:username] == "tzhbami7" && @user_session.save
        format.html { redirect_back_or_default(root_path) }
      else
        format.html do
          flash.now[:error] = "Falsches Passwort und / oder Benutzer"
          render "new"
        end
      end
    end
  end

  # DELETE /user_sessions/1
  # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find(params[:id])
    @user_session.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
    end
  end
end
