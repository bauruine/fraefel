class PurchaseOrder < ActiveRecord::Base
  attr_accessor :is_importing
  has_one :calculation, :as => :calculable, :dependent => :destroy
  belongs_to :category, :class_name => "Category", :foreign_key => "category_id"
  belongs_to :customer, :class_name => "Customer", :foreign_key => "customer_id"
  belongs_to :address, :class_name => "Address", :foreign_key => "address_id"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "level_3"
  has_many :purchase_positions, :class_name => "PurchasePosition", :foreign_key => "purchase_order_id", :dependent => :destroy
  has_many :purchase_order_pallet_assignments
  has_many :pallets, :class_name => "Pallet", :through => :purchase_order_pallet_assignments
  has_many :purchase_order_address_assignments
  has_many :addresses, :class_name => "Address", :through => :purchase_order_address_assignments
  has_many :time_shiftings, :class_name => "TimeShifting", :foreign_key => "purchase_order_id", :primary_key => "baan_id"

  has_one :html_content, :class_name => "HtmlContent"
  has_one :btn_cat_a, :class_name => "HtmlContent", :conditions => {:category_id => 15}
  has_one :btn_cat_b, :class_name => "HtmlContent", :conditions => {:category_id => 16}

  validates :baan_id, :uniqueness => true

  scope :ordered_for_delivery, order("purchase_orders.priority_level desc, purchase_orders.shipping_route_id asc, purchase_orders.customer_id asc, purchase_orders.delivery_date asc, purchase_orders.id asc")

  after_create :handle_calculation
  after_create :handle_html_content

  after_create :update_import_purchase_order
  after_create :redis_sadd_purchase_order_ids
  after_update :redis_sadd_purchase_order_ids, :if => :is_importing
  after_create :handling_address_ids
  after_update :handling_address_ids, :if => :is_importing

  def pending_in_percent
    [100 - self.warehousing_completed, "%"].join
  end

  def stored_in_percent
    [self.warehousing_completed, "%"].join
  end

  def manufactured_in_percent
    [self.manufacturing_completed, "%"].join
  end

  def self.patch_level_3
    select("DISTINCT `purchase_orders`.*").joins(:purchase_positions).each do |purchase_order|
      level_3 = purchase_order.purchase_positions.collect(&:level_3).uniq.compact.first
      purchase_order.update_attribute("level_3", level_3)
    end
  end

  def self.patch_html_content
    self.all.each do |purchase_order|
      purchase_order.patch_html_content
    end
  end

  def patch_html_content
    self.create_html_content if self.html_content.nil?
    buttons = String.new
    buttons += self.pending_status_btn if self.pending_status != 0
    buttons += self.production_status_btn if self.production_status != self.stock_status
    buttons += self.stock_status_btn
    self.html_content.update_column(:code, buttons)
  end

  def self.patch_btn_cat_a
    self.all.each do |purchase_order|
      purchase_order.patch_btn_cat_a
    end
  end

  def patch_btn_cat_a
    self.create_btn_cat_a(:code => "") if self.btn_cat_a.nil?
    self.btn_cat_a.update_attribute("code", self.priority_level_btn)
  end

  def patch_picked_up
    if self.purchase_positions.count != self.purchase_positions.where("purchase_positions.picked_up" => true).count
      self.update_column(:picked_up, false)
    else
      self.update_column(:picked_up, true)
    end
  end

  def patch_delivered
    if self.purchase_positions.count != self.purchase_positions.where("purchase_positions.delivered" => true).count
      self.update_column(:delivered, false)
    else
      self.update_column(:delivered, true)
    end
  end

  def patch_cancelled
    if self.purchase_positions.count != self.purchase_positions.where("purchase_positions.cancelled" => true).count
      self.update_column(:cancelled, false)
    else
      self.update_column(:cancelled, true)
    end
  end

  def self.create_from_raw_data(arg)
    customer_id = Import::Customer.get_mapper_id(:baan_id => arg.attributes["baan_6"])
    shipping_route_id = Import::ShippingRoute.get_mapper_id(:baan_id => arg.attributes["baan_21"]) || 45
    level_1 = Import::Address.get_mapper_id(:baan_id => arg.attributes["baan_55"], :category_id => "8")
    level_2 = Import::Address.get_mapper_id(:baan_id => arg.attributes["baan_47"], :category_id => "9")
    level_3 = Import::Address.get_mapper_id(:baan_id => arg.attributes["baan_71"], :category_id => "10")
    category_id = Import::Category.get_mapper_id(:unique_id => Digest::MD5.hexdigest(%Q(#{arg.attributes["baan_81"]}-purchase_order))) || 13

    purchase_order_attributes = Hash.new
    purchase_order_attributes.merge!("baan_id" => arg.attributes["baan_2"])
    purchase_order_attributes.merge!("customer_id" => customer_id)
    purchase_order_attributes.merge!("shipping_route_id" => shipping_route_id)
    purchase_order_attributes.merge!("warehouse_number" => arg.attributes["baan_22"].to_i)
    purchase_order_attributes.merge!("delivery_date" => arg.attributes["baan_13"])
    purchase_order_attributes.merge!("level_1" => level_1)
    purchase_order_attributes.merge!("level_2" => level_2)
    purchase_order_attributes.merge!("level_3" => level_3)
    purchase_order_attributes.merge!("address_id" => level_3)
    purchase_order_attributes.merge!("category_id" => category_id)

    purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(purchase_order_attributes)

    if purchase_order.new_record?
      purchase_order.save
    else
      do_update = false
      purchase_order_attributes["delivery_date"] = Date.parse(arg.attributes["baan_13"])
      purchase_order_attributes.delete("warehouse_number")

      purchase_order_attributes.each do |k, v|
        if v != purchase_order.attributes[k]
          do_update = true
        end
      end

      if do_update
        purchase_order_attributes["delivery_date"] = arg.attributes["baan_13"]
        purchase_order.is_importing = true

        purchase_order.update_attributes(purchase_order_attributes)
      end
    end
  end

  def self.clean
    where("purchase_orders.baan_id NOT IN(?)", TimeShifting.all.collect(&:purchase_order_id)).where(:delivered => false).where("pallets.id IS NULL").includes(:purchase_positions => :pallets).each do |purchase_order|
      purchase_order.destroy
    end
  end

  def stock_status_btn
    btn_value = self.stock_status
    tag_options = {:class => "btn btn-success btn-mini disabled"}.stringify_keys.to_tag_options

    return "<a #{tag_options}>#{ERB::Util.html_escape(btn_value)}</a>"
  end

  def pending_status_btn
    btn_value = self.pending_status
    tag_options = {:class => "btn btn-danger btn-mini disabled"}.stringify_keys.to_tag_options

    return "<a #{tag_options}>#{ERB::Util.html_escape(btn_value)}</a>"
  end

  def production_status_btn
    btn_value = self.production_status
    tag_options = {:class => "btn btn-primary btn-mini disabled"}.stringify_keys.to_tag_options

    return "<a #{tag_options}>#{ERB::Util.html_escape(btn_value)}</a>"
  end

  def priority_level_btn
    tag_options, span_tag_options = {}, {}
    case
      when self.priority_level == 0 then tag_options.merge!(:class => "icon-asterisk")
      when self.priority_level > 1 then tag_options.merge!(:class => "icon-fire")
    end
    tag_options, span_tag_options = tag_options.stringify_keys.to_tag_options, span_tag_options.merge!(:class => "btn btn-mini disabled btn-warning").stringify_keys.to_tag_options
    return tag_options.present? ? "<span #{span_tag_options}><i #{tag_options}></i></span>" : ""
  end

  def self.recalculate_calculation_total_purchase_positions
    PurchaseOrder.all.each do |purchase_order|
      purchase_order.recalculate_calculation_total_purchase_positions
    end
  end

  def self.recalculate_calculation_total_pallets
    PurchaseOrder.all.each do |purchase_order|
      purchase_order.recalculate_calculation_total_pallets
    end
  end

  def recalculate_calculation_total_purchase_positions
    self.calculation.recalculate_total_purchase_positions
  end

  def recalculate_calculation_total_pallets
    self.calculation.recalculate_total_pallets
  end

  def patch_warehousing_completed
    purchase_positions_cancelled = self.purchase_positions.where("purchase_positions.cancelled" => false)
    if purchase_positions_cancelled.present?
      self.update_column(:warehousing_completed, purchase_positions_cancelled.sum(:stock_status) * (Float(100) / Float(purchase_positions_cancelled.count)))
    end
  end

  def patch_manufacturing_completed
    purchase_positions_cancelled = self.purchase_positions.where("purchase_positions.cancelled" => false)
    if purchase_positions_cancelled.present?
      self.update_column(:manufacturing_completed, purchase_positions_cancelled.sum(:production_status) * (Float(100) / Float(purchase_positions_cancelled.count)))
    end
  end

  def patch_production_status
    purchase_positions_cancelled = self.purchase_positions.where("purchase_positions.cancelled" => false)
    self.update_column(:production_status, purchase_positions_cancelled.sum(:production_status))
  end

  def patch_stock_status
    purchase_positions_cancelled = self.purchase_positions.where("purchase_positions.cancelled" => false)
    self.update_column(:stock_status, purchase_positions_cancelled.sum(:stock_status))
  end

  def patch_workflow_status
    purchase_positions_cancelled = self.purchase_positions.where("purchase_positions.cancelled" => false)
    self.update_column(:workflow_status, [purchase_positions_cancelled.sum(:production_status), purchase_positions_cancelled.sum(:stock_status)].join)
  end

  def patch_pending_status
    purchase_positions_cancelled = self.purchase_positions.where("purchase_positions.cancelled" => false)
    self.update_column(:pending_status, purchase_positions_cancelled.count - purchase_positions_cancelled.sum(:production_status))
  end

  def self.patch_aggregations
    self.all.each do |purchase_order|
      purchase_order.patch_aggregations
    end
  end

  def patch_aggregations
    self.patch_manufacturing_completed
    self.patch_warehousing_completed
    self.patch_production_status
    self.patch_stock_status
    self.patch_workflow_status
    self.patch_pending_status
  end

  def self.patch_addresses
    self.all.each do |purchase_order|
      level_1 = Address.where(:id => purchase_order.level_1).first.try(:id)
      level_2 = Address.where(:id => purchase_order.level_2).first.try(:id)
      level_3 = Address.where(:id => purchase_order.level_3).first.try(:id)
      purchase_order.address_ids = [level_1, level_2, level_3].compact
    end
  end

  def self.patch_workflow_statuses
    self.all.each do |p_o|
      p_o.update_attributes(:stock_status => p_o.purchase_positions.sum(:stock_status), :production_status => p_o.purchase_positions.sum(:production_status), :workflow_status => "#{p_o.purchase_positions.sum(:production_status)}#{p_o.purchase_positions.sum(:stock_status)}")
    end
  end

  def self.patch_import(upload_id)
    csv_file_path = upload_id

    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
    ag = Time.now

    csv_file.each do |row|
      csv_purchase_order = row[0].to_s.undress
      level_1 =  Address.where(:code => row[29].to_s.undress, :category_id => 8).try(:first).try(:id)
      level_2 =  Address.where(:code => row[21].to_s.undress, :category_id => 9).try(:first).try(:id)
      level_3 =  Address.where(:code => row[45].to_s.undress, :category_id => 10).try(:first).try(:id)

      purchase_order = PurchaseOrder.where(:baan_id => csv_purchase_order)

      if purchase_order.present?
        purchase_order.first.update_attributes(:level_1 => level_1, :level_2 => level_2, :level_3 => level_3)
        purchase_order.first.addresses += Address.where(:id => [level_1, level_2, level_3])
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
  end

  def self.clean_up_delivered
    self.where("purchase_orders.picked_up" => false).where("purchase_positions.picked_up" => true).includes(:purchase_positions).each do |p_o|
      if p_o.purchase_positions.count == p_o.purchase_positions.where("purchase_positions.picked_up" => true).count
        p_o.update_attribute("picked_up", true)
      end
    end
  end

  protected

  def handle_calculation
    self.create_calculation unless self.calculation.present?
  end

  def handle_html_content
    self.create_html_content unless self.html_content.present?
  end

  def update_import_purchase_order
    import_purchase_order = Import::PurchaseOrder.find(:baan_id => self.baan_id).first
    unless import_purchase_order.nil?
      import_purchase_order.update(:mapper_id => self.id.to_s)
    end
  end

  def redis_sadd_purchase_order_ids
    Redis.connect.sadd("purchase_order_ids", self.id)
  end

  def handling_address_ids
    self.address_ids = [self.level_1, self.level_2, self.level_3]
  end

end
