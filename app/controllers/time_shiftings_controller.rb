class TimeShiftingsController < ApplicationController
  def show
    @time_shifting = TimeShifting.where(:id => params[:id])
    @purchase_positions = @time_shifting.first.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).includes(:purchase_position_time_shifting_assignments)
    @article_positions = @time_shifting.first.article_positions.order("created_at DESC")
    @purchase_order = PurchaseOrder.where(:baan_id => @time_shifting.first.purchase_order_id)
    @comments = @time_shifting.first.comments.order("created_at DESC")
    @departments = @time_shifting.first.department_time_shifting_assignments.order("department_time_shifting_assignments.created_at DESC").includes(:department, :creator)
    
    respond_to do |format|
      format.html
      format.pdf do
        render( 
          :pdf => "Kein Titel-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Portrait',
          :encoding => 'UTF-8',
          :footer => {
            :left => "#{Time.now.to_formatted_s(:swiss_date)}",
            :right => "Seite [page] / [topage]",
            :line => false
          }
        )
      end
    end
    
  end
  
  def index
    @time_shiftings = TimeShifting.order("updated_at DESC")
    
    respond_to do |format|
      format.html
      format.pdf do
        render( 
          :pdf => "Kein Titel-#{Date.today}",
          :wkhtmltopdf => '/usr/bin/wkhtmltopdf',
          :layout => 'pdf.html',
          :show_as_html => params[:debug].present?,
          :orientation => 'Landscape',
          :encoding => 'UTF-8',
          :footer => {
            :left => "#{Time.now.to_formatted_s(:swiss_date)}",
            :right => "Seite [page] / [topage]",
            :line => false
          }
        )
      end
    end
    
  end
  
  def new
    @time_shifting = TimeShifting.new(params[:time_shifting])
    @departments = Department.order("departments.title ASC")
    
    if params[:time_shifting].present?
       @purchase_order = PurchaseOrder.where(:baan_id => params[:time_shifting][:purchase_order_id])
       @purchase_positions = @purchase_order.first.purchase_positions
       @shifting_reasons = ShiftingReason.where("departments.id IN(?)", User.current.departments(&:id)).includes(:departments)
       
       @time_shifting.comments.build
       @time_shifting.department_time_shifting_assignments.build
       @time_shifting.shifting_reason_time_shifting_assignments.build
       
       @purchase_positions.each do |purchase_position|
         @time_shifting.purchase_position_time_shifting_assignments.build(:purchase_position_id => purchase_position.id)
      end
    end
    
  end
  
  def create
    @time_shifting = TimeShifting.new(params[:time_shifting])
    if @time_shifting.save
      PurchaseOrder.where(:baan_id => @time_shifting.purchase_order_id).first.update_attribute("priority_level", 1)
      redirect_to(time_shiftings_path)
    else
      render 'new'
    end
  end
  
  def edit
    @time_shifting = TimeShifting.where(:id => params[:id])
    @purchase_positions = @time_shifting.first.purchase_position_time_shifting_assignments.includes(:purchase_position)
    @shifting_reasons = ShiftingReason.where("departments.id IN(?)", User.current.departments(&:id)).includes(:departments)
    @departments = Department.order("departments.title ASC")
    @purchase_order = PurchaseOrder.where(:baan_id => @time_shifting.first.purchase_order_id)
    @time_shifting.first.comments.build
    @time_shifting.first.department_time_shifting_assignments.build
    #@time_shifting.first.shifting_reason_time_shifting_assignments.build
  end
  
  def update
    @time_shifting = TimeShifting.where(:id => params[:id])
    if @time_shifting.first.update_attributes(params[:time_shifting])
      ### Move this logic to a filter!!
      if @time_shifting.first.department_time_shifting_assignments.where("completed_at IS NULL").count > 1
        @time_shifting.first.department_time_shifting_assignments.where("completed_at IS NULL").first.update_attribute("completed_at", Time.now)
      end
      redirect_to(@time_shifting.first)
    end
  end
  
end
