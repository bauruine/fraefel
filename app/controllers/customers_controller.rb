class CustomersController < FraefelController
  def show
    @customer = Customer.find(params[:id])
    @versions = @customer.versions
    @purchase_orders = @customer.purchase_orders.includes(:purchase_positions).order("purchase_positions.delivery_date asc")
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        @customers = Customer.order(:id).where("company like ?", "%#{params[:term]}%")
        render json: @customers.map(&:company)
      end
    end
  end

  def new
    if params[:import] == "true"
      import
    end
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(params[:customer])
    if @customer.save
      redirect_to customers_url
    else
      render 'new'
    end
  end

  def edit

  end

  def update
    @customer = Customer.find(params[:id])
    if params[:version]
      version = Version.find(params[:version])
      if version.reify.save!
        redirect_to customer_url(@customer)
      end
    else
      if @customer.update_attributes(params[:customer])
        redirect_to customer_url(@customer)
      else
        render 'edit'
      end
    end
  end

  def destroy

  end

  private

  def import
    CSV.foreach("import/csv/export/11-08-24-export_SpediListe.csv", {:col_sep => ";", :headers => :first_row, :encoding => Encoding.find('UTF-8')}) do |row|
      data_array = row[3].split(',')
      company = data_array[0].strip
      street = data_array[1].strip
      city = data_array[2].match('(.+)-(\d+)(.+)').nil? ? nil : data_array[2].match('(.+)-(\d+)(.+)')[3]
      country = data_array[2].match('(.+)-(\d+)(.+)').nil? ? nil : data_array[2].match('(.+)-(\d+)(.+)')[1]
      zip = data_array[2].match('(.+)-(\d+)(.+)').nil? ? nil : data_array[2].match('(.+)-(\d+)(.+)')[2]

      if Customer.where("company LIKE '%#{company}%'").empty?
        Customer.create(:company => company, :street => street, :country => country, :zip => zip, :city => city)
      end
    end
    redirect_to(customers_url)
  end
end
