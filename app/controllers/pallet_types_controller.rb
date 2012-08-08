class PalletTypesController < ApplicationController
  def index
    @pallet_types = PalletType.order("pallet_types.read_as ASC, pallet_types.count_as ASC")
  end

  def show
  end

  def new
    @pallet_type = PalletType.new
  end

  def create
    @pallet_type = PalletType.new(params[:pallet_type])
    if @pallet_type.save
      redirect_to pallet_types_path
    else
      render 'edit'
    end
  end

  def edit
    @pallet_type = PalletType.find(params[:id])
  end

  def update
    @pallet_type = PalletType.find(params[:id])
    if @pallet_type.update_attributes(params[:pallet_type])
      redirect_to pallet_types_path
    else
      render 'edit'
    end
  end
end
