# encoding: utf-8

class UsersController < FraefelController
  filter_resource_access
  # GET /users
  # GET /users.xml
  def index
    @users = User.order("surname ASC, forename ASC").includes(:roles)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id].present? ? params[:id]: current_user.id)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(users_path, :notice => 'User was successfully created.') }
      else
        format.html { render :action => "new", :error => "Konnte neuen User nicht erstellen!" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(users_path, :notice => 'User was successfully updated.') }
      else
        format.html { render 'edit' }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end
end
