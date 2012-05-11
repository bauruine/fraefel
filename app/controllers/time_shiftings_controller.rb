class TimeShiftingsController < ApplicationController
  def show
    @time_shifting = TimeShifting.where(:id => params[:id])
    @purchase_positions = @time_shifting.first.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).includes(:purchase_position_time_shifting_assignments)
    @article_positions = @time_shifting.first.article_positions.order("created_at DESC")
    @purchase_order = PurchaseOrder.where(:baan_id => @time_shifting.first.purchase_order_id)
    @comments = @time_shifting.first.comments.order("created_at DESC")
    
  end
  
  def index
    @time_shiftings = TimeShifting.order("updated_at DESC")
  end
  
  def new
    @time_shifting = TimeShifting.new(params[:time_shifting])
    @departments = Department.order("departments.title ASC")
    
    if params[:time_shifting].present?
       @purchase_order = PurchaseOrder.where(:baan_id => params[:time_shifting][:purchase_order_id])
       @purchase_positions = @purchase_order.first.purchase_positions
       @shifting_reasons = ShiftingReason.where("departments.id IN(?)", User.current.departments(&:id)).includes(:departments)
       
       @time_shifting.comments.build
       @time_shifting.shifting_reason_time_shifting_assignments.build
       
       @purchase_positions.each do |purchase_position|
         @time_shifting.purchase_position_time_shifting_assignments.build(:purchase_position_id => purchase_position.id)
      end
    end
    
  end
  
  def create
    @time_shifting = TimeShifting.new(params[:time_shifting])
    if @time_shifting.save
      redirect_to(time_shiftings_path)
    end
  end
  
  def edit
    @time_shifting = TimeShifting.where(:id => params[:id])
    @purchase_positions = @time_shifting.first.purchase_position_time_shifting_assignments.includes(:purchase_position)
    @shifting_reasons = ShiftingReason.where("departments.id IN(?)", User.current.departments(&:id)).includes(:departments)
    @departments = Department.order("departments.title ASC")
    @purchase_order = PurchaseOrder.where(:baan_id => @time_shifting.first.purchase_order_id)
    @time_shifting.first.comments.build
    #@time_shifting.first.shifting_reason_time_shifting_assignments.build
  end
  
  def update
    @time_shifting = TimeShifting.where(:id => params[:id])
    if @time_shifting.first.update_attributes(params[:time_shifting])
      redirect_to(@time_shifting.first)
    end
  end
  
end
