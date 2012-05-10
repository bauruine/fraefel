class ShiftingReasonsController < ApplicationController
  def index
    @shifting_reasons = ShiftingReason.order("shifting_reasons.title ASC")
  end
  
  def new
    @shifting_reason = ShiftingReason.new
  end
  
  def create
    @shifting_reason = ShiftingReason.new(params[:shifting_reason])
    
    if @shifting_reason.save
      redirect_to(shifting_reasons_path)
    end
  end
  
  def edit
    @shifting_reason = ShiftingReason.where(:id => params[:id]).first
  end
  
  def update
    @shifting_reason = ShiftingReason.where(:id => params[:id])
    
    if @shifting_reason.first.update_attributes(params[:shifting_reason])
      redirect_to(shifting_reasons_path)
    end
  end
  
end
