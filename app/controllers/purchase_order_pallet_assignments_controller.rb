class PurchaseOrderPalletAssignmentsController < FraefelController
  def new

  end

  def create

  end

  def edit
    @pallet = Pallet.find(params[:pallet_id])

  end

  def update

  end
end
