class PurchasePosition < ActiveRecord::Base
  attr_accessor :is_importing

  belongs_to :commodity_code, :class_name => "CommodityCode", :foreign_key => "commodity_code_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :old_pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :zip_location, :class_name => "ZipLocation", :foreign_key => "zip_location_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "level_3"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"

  has_one :html_content, :class_name => "HtmlContent"

  has_many :pallet_purchase_position_assignments, :class_name => "PalletPurchasePositionAssignment"
  has_many :pallets, :class_name => "Pallet", :through => :pallet_purchase_position_assignments

  has_many :transport_issues
  has_many :delivery_rejections, :through => :transport_issues

  has_many :purchase_position_time_shifting_assignments
  has_many :time_shiftings, :class_name => "TimeShifting", :through => :purchase_position_time_shifting_assignments

  has_many :delivery_dates, :as => :dateable

  validates :baan_id, :uniqueness => true

  after_create :redis_sadd_purchase_order_ids
  after_create :creation_delivery_dates_if_new_record
  after_create :after_create_1
  after_update :redis_sadd_purchase_order_ids, :if => :is_importing
  after_update :creation_delivery_dates_if_updating, :if => :is_importing

  def shipping_route_name
    read_attribute("shipping_route_name") || self.shipping_route.name
  end

  def purchase_order_baan_id
    read_attribute("purchase_order_baan_id") || self.purchase_order.baan_id
  end

  def self.patch_level_3
    select("DISTINCT `purchase_positions`.*").joins(:purchase_order).readonly(false).each do |purchase_position|
      @level_3_id = purchase_position.purchase_order.level_3
      purchase_position.update_attribute("level_3", @level_3_id)
    end
  end

  def self.patch_shipping_route_id
    select("DISTINCT `purchase_positions`.*").joins(:purchase_order).readonly(false).each do |purchase_position|
      @shipping_route_id = purchase_position.purchase_order.shipping_route_id
      purchase_position.update_attribute("shipping_route_id", @shipping_route_id)
    end
  end

  def self.patch_baan_id
    select("DISTINCT `purchase_positions`.*").joins(:purchase_order).readonly(false).each do |purchase_position|
      @purchase_order_baan_id = purchase_position.purchase_order.baan_id
      @purchase_position_baan_id = "#{@purchase_order_baan_id}-#{purchase_position.position}"
      purchase_position.update_attribute("baan_id", @purchase_position_baan_id)
    end
  end

  def self.patch_html_content
    self.all.each do |purchase_position|
      purchase_position.patch_html_content
    end
  end

  def patch_html_content
    self.create_html_content(:code => "") if self.html_content.nil?
    html_string = self.priority_level_btn
    self.html_content.update_attribute("code", html_string)
  end

  def priority_level_btn
    html_string = String.new
    if self.priority_level == 0 or self.priority_level > 1
      html_string += %q(<span class="btn btn-mini disabled">)
      if self.priority_level == 0
        html_string += %q(<i class="icon-asterisk"></i>)
      elsif self.priority_level > 1
        html_string += %q(<i class="icon-fire"></i>)
      end
      html_string += %q(</span>)
    end
    return html_string
  end

  def available_quantity
    self.quantity.to_i - self.pallet_purchase_position_assignments.sum("quantity")
  end

  def in_mixed_pallet?(*args)
    self.purchase_order != args.first
  end

  def nil_or_zero?
    self.weight_total.to_f == 0.to_f || self.amount.to_f == 0
  end
  def self.patch_gross_net_value_discount
    self.all.each do |purchase_position|
      gross_price = purchase_position.gross_price.present? ? purchase_position.gross_price : purchase_position.amount
      net_price = purchase_position.net_price.present? ? purchase_position.net_price : purchase_position.amount
      value_discount = purchase_position.value_discount.present? ? purchase_position.value_discount : 0
      purchase_position.update_attributes(:gross_price => gross_price, :net_price => net_price, :value_discount => value_discount)
    end
  end

  # TODO: remove ?
  def self.update_from_raw_data(arg)
    purchase_position_attributes = Hash.new
    purchase_position_attributes.merge!(:quantity => arg.attributes["baan_18"].to_f)
    purchase_position_attributes.merge!(:stock_status => arg.attributes["baan_79"].to_i)
    purchase_position_attributes.merge!(:production_status => arg.attributes["baan_79"].to_i)
    purchase_position_attributes.merge!(:picked_up => arg.attributes["baan_84"])

    purchase_position = PurchasePosition.where(:baan_id => "#{arg.attributes["baan_2"]}-#{arg.attributes["baan_4"]}").first

    if purchase_position.present?
      purchase_position.is_importing = true
      purchase_position.update_attributes(purchase_position_attributes)
    end
  end

  def self.jaintor_from_raw_data(arg)
    purchase_position_attributes = Hash.new
    purchase_position_attributes.merge!(:cancelled => true)

    purchase_position = PurchasePosition.where(:baan_id => "#{arg.attributes["baan_2"]}-#{arg.attributes["baan_4"]}").first

    if purchase_position.present?
      purchase_position.is_importing = true
      purchase_position.update_attributes(purchase_position_attributes)
    end
  end

  def self.create_from_raw_data(arg)
    commodity_code_id = Import::CommodityCode.get_mapper_id(:baan_id => arg.attributes["baan_0"])
    purchase_order_id = Import::PurchaseOrder.get_mapper_id(:baan_id => arg.attributes["baan_2"])
    level_3 = Import::Address.get_mapper_id(:baan_id => arg.attributes["baan_71"], :category_id => "10")
    zip_location_id = Import::ZipLocation.get_mapper_id(:baan_id => arg.attributes["baan_35"])
    shipping_route_id = Import::ShippingRoute.get_mapper_id(:baan_id => arg.attributes["baan_21"]) || 45

    purchase_position_attributes = Hash.new
    purchase_position_attributes.merge!("commodity_code_id" => commodity_code_id)
    purchase_position_attributes.merge!("purchase_order_id" => purchase_order_id)
    purchase_position_attributes.merge!("baan_id" => "#{arg.attributes["baan_2"]}-#{arg.attributes["baan_4"]}")
    purchase_position_attributes.merge!("position" => arg.attributes["baan_4"].to_i)
    purchase_position_attributes.merge!("delivery_date" => Date.parse(arg.attributes["baan_13"]))
    purchase_position_attributes.merge!("weight_single" => BigDecimal(arg.attributes["baan_15"]))
    purchase_position_attributes.merge!("weight_total" => BigDecimal(arg.attributes["baan_16"]))
    purchase_position_attributes.merge!("amount" => BigDecimal(arg.attributes["baan_17"]))
    purchase_position_attributes.merge!("quantity" => arg.attributes["baan_18"].to_i)
    purchase_position_attributes.merge!("storage_location" => arg.attributes["baan_23"])
    purchase_position_attributes.merge!("article_number" => arg.attributes["baan_27"])
    purchase_position_attributes.merge!("article" => arg.attributes["baan_28"])
    purchase_position_attributes.merge!("product_line" => arg.attributes["baan_30"])
    purchase_position_attributes.merge!("level_3" => level_3)
    purchase_position_attributes.merge!("shipping_route_id" => shipping_route_id)
    purchase_position_attributes.merge!("zip_location_id" => zip_location_id)
    purchase_position_attributes.merge!("gross_price" => BigDecimal(arg.attributes["baan_38"]))
    purchase_position_attributes.merge!("value_discount" => BigDecimal(arg.attributes["baan_39"]))
    purchase_position_attributes.merge!("net_price" => BigDecimal(arg.attributes["baan_40"]))
    purchase_position_attributes.merge!("stock_status" => arg.attributes["baan_78"].to_i)
    purchase_position_attributes.merge!("production_status" => arg.attributes["baan_79"].to_i)
    purchase_position_attributes.merge!("picked_up" => arg.attributes["baan_84"].to_i)
    purchase_position_attributes["picked_up"] = purchase_position_attributes["picked_up"] == 1 ? true : false

    purchase_position = PurchasePosition.where(:baan_id => purchase_position_attributes["baan_id"]).first
    purchase_position ||= PurchasePosition.new(purchase_position_attributes)

    if purchase_position.new_record?
      purchase_position.save
    else
      purchase_position.attributes = purchase_position_attributes
      if purchase_position.changed?
        purchase_position.is_importing = true
        purchase_position.save
      end
    end
  end

  protected

  def redis_sadd_purchase_order_ids
    Redis.connect.sadd("purchase_order_ids", self.purchase_order_id)
  end

  # INFO: Fire up patcher in PurchaseOrder -> patch_delivered
  def update_purchase_order_delivered
    self.purchase_order.patch_delivered
  end

  def creation_delivery_dates_if_new_record
    self.delivery_dates.create(:date_of_delivery => self.delivery_date)
  end

  def creation_delivery_dates_if_updating
    if self.delivery_date != self.delivery_dates.last.try(:date_of_delivery)
      self.delivery_dates.create(:date_of_delivery => self.delivery_date)
    end
  end

  def after_create_1
    self.patch_html_content
  end

  def self.clean_up_delivered(arg)
    @baan_import = BaanImport.find(arg)

    ag = Time.now
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      purchase_position_attributes = {}

      purchase_position_attributes.merge!(:quantity => baan_raw_data.attributes["baan_18"].to_f)
      purchase_position_attributes.merge!(:stock_status => baan_raw_data.attributes["baan_79"].to_i)
      purchase_position_attributes.merge!(:production_status => baan_raw_data.attributes["baan_79"].to_i)
      purchase_position_attributes.merge!(:picked_up => baan_raw_data.attributes["baan_84"])

      @purchase_position = PurchasePosition.where(:baan_id => "#{baan_raw_data.attributes["baan_2"]}-#{baan_raw_data.attributes["baan_4"]}")

      if @purchase_position.present?
        # update purchase_position
        @purchase_position.first.update_attributes(purchase_position_attributes)
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end

end
