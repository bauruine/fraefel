# encoding: utf-8

class MicrosoftDatabasesController < FraefelController
  filter_resource_access
  require 'csv'
  before_filter :import

  def index
    @microsoft_databases = MicrosoftDatabase.where(:name.matches => "%#{params[:search]}%").page(params[:page])
  end

  def new
    @microsoft_database = MicrosoftDatabase.new
  end

  def create
    @microsoft_database = MicrosoftDatabase.new(params[:microsoft_database])
    regexed_array = !@microsoft_database.file.empty? ? @microsoft_database.file.match('(.+):\/\/((.+)\/((.+)\.(.+)))') : nil
    @microsoft_database.file = regexed_array[2] if regexed_array
    @microsoft_database.file_directory = regexed_array[3] if regexed_array
    if @microsoft_database.save
      redirect_to microsoft_databases_url, :notice => "Successfully created microsoft database."
    else
      render :action => 'new'
    end
  end

  def edit
    @microsoft_database = MicrosoftDatabase.find(params[:id])
  end

  def update
    @microsoft_database = MicrosoftDatabase.find(params[:id])
    if @microsoft_database.update_attributes(params[:microsoft_database])
      redirect_to microsoft_databases_url, :notice => "Successfully updated microsoft database."
    else
      render :action => 'edit'
    end
  end

  private

  def import
    if MicrosoftDatabase.count == 0
      CSV.foreach("import/csv/microsoft_databases/11-08-14-export.csv", {:col_sep => ";", :headers => :first_row}) do |row|
        microsoft_database = MicrosoftDatabase.new
        microsoft_database.name = row[1]
        microsoft_database.database_type = MicrosoftDatabaseType.find_or_create_by_name(:name => row[6], :description => row[7])
        microsoft_database.file = row[10]
        microsoft_database.file_directory = row[11]
        microsoft_database.save
      end
    end
  end
end
