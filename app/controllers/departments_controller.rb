# encoding: utf-8

class DepartmentsController < FraefelController

  def index
    @departments = Department.order("departments.title ASC")
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(params[:department])

    if @department.save
      redirect_to(departments_path)
    end
  end

  def edit
    @department = Department.where(:id => params[:id]).first
  end

  def update
    @department = Department.where(:id => params[:id])

    if @department.first.update_attributes(params[:department])
      redirect_to(departments_path)
    end
  end

end
