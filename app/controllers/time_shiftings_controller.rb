class TimeShiftingsController < ApplicationController
  before_filter :collect_departments, :only => :index
  before_filter :collect_shifting_reasons, :only => :index
  
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
          :pdf => "fraefel_app-#{Date.today}",
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
    # @search = TimeShifting.includes(:purchase_order).order("time_shiftings.id DESC, time_shiftings.lt_date ASC, time_shiftings.purchase_order_id ASC").search(params[:search] || {:closed_equals => "false"})
    @search = TimeShifting.order("time_shiftings.id DESC, time_shiftings.lt_date ASC").search(params[:q] || {:closed_eq => "false"})
    
    @time_shiftings = @search.result
    
    #@requested_department_id = params["search"]["department_id_equals"] if params[:search]

    
    respond_to do |format|
      format.html
      format.pdf do
        if params[:pdf_type].present? && params[:pdf_type] == "article_positions"
          @time_shiftings = @time_shiftings.where("article_positions.id IS NOT NULL").includes(:article_positions)
        end
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
    @purchase_order = (params[:time_shifting].present? && params[:time_shifting][:purchase_order_id].present?) ? PurchaseOrder.where(:baan_id => params[:time_shifting][:purchase_order_id]) : nil
    
    if @purchase_order.present?
       @purchase_positions = @purchase_order.first.purchase_positions
       @shifting_reasons = ShiftingReason.where("departments.id IN(?)", User.current.departments(&:id)).includes(:departments)
       
       @time_shifting.comments.build
       #@time_shifting.shifting_reason_time_shifting_assignments.build
       
       @purchase_positions.each do |purchase_position|
         @time_shifting.purchase_position_time_shifting_assignments.build(:purchase_position_id => purchase_position.id)
      end
    end
    
  end
  
  def create
    @time_shifting = TimeShifting.new(params[:time_shifting])
    @departments = Department.order("departments.title ASC")
    @purchase_order = PurchaseOrder.where(:baan_id => @time_shifting.purchase_order_id)
    @purchase_positions = @purchase_order.first.purchase_positions
    @shifting_reasons = ShiftingReason.where("departments.id IN(?)", User.current.departments(&:id)).includes(:departments)
    
    
    @time_shifting.comments.build if @time_shifting.comments.empty?
    
    if @time_shifting.save
      @time_shifting.departments << @time_shifting.department
      PurchaseOrder.where(:baan_id => @time_shifting.purchase_order_id).first.update_attribute("priority_level", 0)
      ### Move this away from here....
      @time_shifting.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).includes(:purchase_position_time_shifting_assignments).update_all(:priority_level => 0)
      redirect_to(time_shiftings_path)
    else
      render 'new'
    end
  end
  
  def edit
    @time_shifting = TimeShifting.where(:id => params[:id])
    # @time_shifting.first.department = nil
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
    @purchase_order = PurchaseOrder.where(:baan_id => @time_shifting.first.purchase_order_id)
    @purchase_positions = @time_shifting.first.purchase_position_time_shifting_assignments.includes(:purchase_position)
    @departments = Department.order("departments.title ASC")
    
    if @time_shifting.first.update_attributes(params[:time_shifting])
      if @time_shifting.first.department_id != @time_shifting.first.departments.last.id
        @time_shifting.first.departments << @time_shifting.first.department
      end
      ### Move this logic to a filter!!
      if @time_shifting.first.department_time_shifting_assignments.where("completed_at IS NULL").count > 1
        @time_shifting.first.department_time_shifting_assignments.where("completed_at IS NULL").first.update_attribute("completed_at", Time.now)
      end
      if @time_shifting.first.closed && @time_shifting.first.lt_date.present?
        @purchase_order.first.priority_level = 2
        @purchase_order.first.save
        @time_shifting.first.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).includes(:purchase_position_time_shifting_assignments).update_all(:priority_level => 2)
      end
      if @time_shifting.first.lt_date.present?
        @time_shifting.first.purchase_positions.where("purchase_position_time_shifting_assignments.considered" => true).includes(:purchase_position_time_shifting_assignments).each do |purchase_position|
          purchase_position.delivery_dates.last.try(:date_of_delivery) != purchase_position.delivery_date.to_date ? purchase_position.delivery_dates.create(:date_of_delivery => @time_shifting.first.lt_date) : nil
          purchase_position.update_attribute(:delivery_date, @time_shifting.first.lt_date)
        end
        @purchase_order.first.update_attribute("delivery_date", @time_shifting.first.lt_date)
      end
      
      redirect_to(@time_shifting.first)
    else
      render 'edit'
    end
  end
  
  private
  
  def collect_departments
    closed_condition = false
    if params[:search].present?
      if params[:search][:closed_equals] == "true"
        closed_condition = true
      end
    end
    @departments = Department.includes(:time_shiftings).where("time_shiftings.id IS NOT NULL").where("time_shiftings.closed = ?", closed_condition).order("departments.title ASC")
  end
  
  def collect_shifting_reasons
    closed_condition = false
    if params[:search].present?
      if params[:search][:closed_equals] == "true"
        closed_condition = true
      end
    end
    @shifting_reasons = ShiftingReason.includes(:time_shiftings).where("time_shiftings.id IS NOT NULL").where("time_shiftings.closed = ?", closed_condition).order("shifting_reasons.title ASC")
  end
  
end
