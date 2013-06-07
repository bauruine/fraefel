class RolesController < FraefelController
  filter_resource_access

  def index
    @roles = Role.page(params[:page]).per(1000)
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @roles }
    end
  end

  def show
    # @role = Role.find(params[:id])
    @users = @role.users
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to roles_url
    else
      render 'new'
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end
end
