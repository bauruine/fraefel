# encoding: utf-8

class VersionsController < FraefelController
  def update

  end

  def destroy
    @version = Version.find(params[:id])
    @version.destroy

    redirect_to(:back)
  end
end
