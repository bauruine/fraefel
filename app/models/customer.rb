class Customer < ActiveRecord::Base
  validates_presence_of :company
  has_many :shipping_addresses, :class_name => "ShippingAddress", :foreign_key => "customer_id"
  has_many :purchase_orders, :class_name => "PurchaseOrder", :foreign_key => "customer_id"
  has_many :referees, :class_name => "Referee", :foreign_key => "customer_id"
  has_many :addresses, :class_name => "Address", :foreign_key => "customer_id"
  has_many :delivery_rejections, :class_name => "DeliveryRejection", :foreign_key => "customer_id"

  accepts_nested_attributes_for :shipping_addresses

  after_create :update_import_customer

  def simplified
    self.company.downcase.delete(' ')
  end

  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    PaperTrail.whodunnit = 'System'

    customer_attributes = {}

    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      customer_attributes.merge!(:company => baan_raw_data.attributes["baan_5"])
      customer_attributes.merge!(:baan_id => baan_raw_data.attributes["baan_6"])

      customer = Customer.find_or_create_by_baan_id(customer_attributes)
    end
  end

  def self.create_from_raw_data(arg)
    customer_attributes = Hash.new

    customer_attributes.merge!(:company => arg.attributes["baan_5"])
    customer_attributes.merge!(:baan_id => arg.attributes["baan_6"])

    customer = Customer.where(:baan_id => customer_attributes[:baan_id]).first
    customer ||= Customer.new(customer_attributes)

    if customer.new_record?
      customer.save
    else
      customer.attributes = customer_attributes
      if customer.changed?
        customer.save
      end
    end
  end

  protected

  def update_import_customer
    import_customer = Import::Customer.find(:baan_id => self.baan_id).first
    unless import_customer.nil?
      import_customer.update(:mapper_id => self.id.to_s)
    end
  end

end
