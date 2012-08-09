class PurchaseOrder < ActiveRecord::Base
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
  has_many :old_pallets, :class_name => "Pallet", :foreign_key => "purchase_order_id"
  has_many :time_shiftings, :class_name => "TimeShifting", :foreign_key => "purchase_order_id", :primary_key => "baan_id"
  
  has_one :html_content, :class_name => "HtmlContent"
  
  scope :ordered_for_delivery, order("purchase_orders.priority_level desc, purchase_orders.shipping_route_id asc, purchase_orders.customer_id asc, purchase_orders.delivery_date asc, purchase_orders.id asc")
  
  after_create :handle_calculation
  
  def self.patch_level_3
    select("DISTINCT `purchase_orders`.*").joins(:purchase_positions).each do |purchase_order|
      level_3 = purchase_order.purchase_positions.collect(&:level_3).uniq.compact.first
      purchase_order.update_attribute("level_3", level_3)
    end
  end
  
  def self.patch_html_content
    self.all.each do |purchase_order|
      purchase_order.create_html_content if purchase_order.html_content.nil?
      buttons = String.new
      buttons += purchase_order.pending_status_btn if purchase_order.pending_status != 0
      buttons += purchase_order.production_status_btn if purchase_order.production_status != purchase_order.stock_status
      buttons += purchase_order.stock_status_btn
      purchase_order.html_content.update_attribute("code", buttons)
    end
  end
  
  
  
  def self.get_performance_time
    @time_start = Time.now
    self.includes(:purchase_positions)
    @time_stop = Time.now
    
    return @time_stop - @time_start
  end
  
  def self.create_from_raw_data(arg)
    customer_id = Customer.where(:baan_id => arg.attributes["baan_6"]).first.try(:id)
    shipping_route_id = ShippingRoute.where(:name => arg.attributes["baan_21"]).first.try(:id)
    level_1 = Address.where(:code => arg.attributes["baan_55"], :category_id => 8).first.try(:id)
    level_2 = Address.where(:code => arg.attributes["baan_47"], :category_id => 9).first.try(:id)
    level_3 = Address.where(:code => arg.attributes["baan_71"], :category_id => 10).first.try(:id)
    category_id = Category.find_or_create_by_title_and_categorizable_type(:title => arg.attributes["baan_81"], :categorizable_type => "purchase_order").id
    
    purchase_order_attributes = Hash.new
    purchase_order_attributes.merge!(:baan_id => arg.attributes["baan_2"])
    purchase_order_attributes.merge!(:customer_id => customer_id)
    purchase_order_attributes.merge!(:shipping_route_id => shipping_route_id)
    purchase_order_attributes.merge!(:warehouse_number => arg.attributes["baan_22"])
    purchase_order_attributes.merge!(:delivery_date => arg.attributes["baan_13"])
    purchase_order_attributes.merge!(:level_2 => level_2)
    purchase_order_attributes.merge!(:level_1 => level_1)
    purchase_order_attributes.merge!(:level_3 => level_3)
    purchase_order_attributes.merge!(:address_id => level_3)
    purchase_order_attributes.merge!(:category_id => category_id)

    # Set Error ShippingRoute if there is no shipping_route_id assigned to this purchase_order
    purchase_order_attributes[:shipping_route_id] = ShippingRoute.where(:name => "ERROR").first.id unless purchase_order_attributes[:shipping_route_id].present?
    
    purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(purchase_order_attributes)
    
    if purchase_order.new_record?
      purchase_order.save
    else
      update_entry = false
      purchase_order_attributes.merge!(:id => purchase_order.id)
      purchase_order_attributes.each do |k, v|
        if purchase_order.attributes[k] != v
          update_entry = true
        end
      end
      if update_entry
        purchase_order_attributes.delete(:id)
        purchase_order.update_attributes(purchase_order_attributes)
      end
    end
    
    purchase_order.address_ids = [level_1, level_2, level_3]

  end
  
  def self.clean
    where("purchase_orders.baan_id NOT IN(?)", TimeShifting.all.collect(&:purchase_order_id)).where(:delivered => false).where("pallets.id IS NULL").includes(:purchase_positions => :pallets).each do |purchase_order|
      purchase_order.destroy
    end
  end
  
  def stock_status_btn
    url = Rails.application.routes.url_helpers.api_purchase_positions_path(:format => :xml, :q => {:purchase_order_baan_id_eq => self.baan_id, :stock_status_eq => 1})
    btn_value = self.stock_status
    tag_options = {:class => "btn btn-success btn-mini", "data-toggle" => "modal-remote", "data-target" => "#remote"}.stringify_keys.to_tag_options
    href_attr = "href=\"#{ERB::Util.html_escape(url)}\""
    
    return "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(btn_value)}</a>"
  end
  
  def pending_status_btn
    url = Rails.application.routes.url_helpers.api_purchase_positions_path(:format => :xml, :q => {:purchase_order_baan_id_eq => self.baan_id, :stock_status_eq => 0, :production_status => 0})
    btn_value = self.pending_status
    tag_options = {:class => "btn btn-danger btn-mini", "data-toggle" => "modal-remote", "data-target" => "#remote"}.stringify_keys.to_tag_options
    href_attr = "href=\"#{ERB::Util.html_escape(url)}\""
    
    return "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(btn_value)}</a>"
  end

  def production_status_btn
    url = Rails.application.routes.url_helpers.api_purchase_positions_path(:format => :xml, :q => {:purchase_order_baan_id_eq => self.baan_id, :production_status_eq => 1})
    btn_value = self.production_status
    tag_options = {:class => "btn btn-primary btn-mini", "data-toggle" => "modal-remote", "data-target" => "#remote"}.stringify_keys.to_tag_options
    href_attr = "href=\"#{ERB::Util.html_escape(url)}\""
    
    return "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(btn_value)}</a>"
  end

  def amount
    amount = 0
    purchase_positions.each do |purchase_position|
      amount = amount + purchase_position.amount
    end
    return amount
  end
  
  def weight_total
    weight_total = 0
    purchase_positions.each do |purchase_position|
      weight_total = weight_total + purchase_position.weight_total
    end
    return weight_total
  end
  
  def self.patch_calculation(arg)
    @purchase_order = PurchaseOrder.where(:baan_id => arg)
    if @purchase_order.present?
      @purchase_order.each do |p_o|
        p_o.create_calculation unless p_o.calculation.present?
        p_o.calculation.update_attributes(:total_pallets => p_o.pallets.count, :total_purchase_positions => p_o.purchase_positions.where("purchase_positions.cancelled" => false).count)
      end
    end
  end
  
  def self.patch_aggregations(arg)
    @purchase_order = PurchaseOrder.where(:baan_id => arg)
    if @purchase_order.present?
      @purchase_order.each do |p_o|
        m_c_status = p_o.purchase_positions.where("purchase_positions.cancelled" => false).sum(:production_status) * (100.to_f / p_o.purchase_positions.where("purchase_positions.cancelled" => false).count.to_f)
        w_c_status = p_o.purchase_positions.where("purchase_positions.cancelled" => false).sum(:stock_status) * (100.to_f / p_o.purchase_positions.where("purchase_positions.cancelled" => false).count.to_f)
        workflow_status = "#{p_o.purchase_positions.where("purchase_positions.cancelled" => false).sum(:production_status)}#{p_o.purchase_positions.where("purchase_positions.cancelled" => false).sum(:stock_status)}"
        m_c_level = p_o.purchase_positions.where("purchase_positions.cancelled" => false).sum(:production_status)
        w_c_level = p_o.purchase_positions.where("purchase_positions.cancelled" => false).sum(:stock_status)
        @pending_status = p_o.calculation.try(:total_purchase_positions) - m_c_level
        p_o.update_attributes(:manufacturing_completed => m_c_status, :warehousing_completed => w_c_status, :production_status => m_c_level, :stock_status => w_c_level, :workflow_status => workflow_status, :pending_status => @pending_status)
      end
    end
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
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    ag = Time.now
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      purchase_order_attributes = {}
      
      purchase_order_attributes.merge!(:baan_id => baan_raw_data.attributes["baan_2"])
      purchase_order_attributes.merge!(:customer_id => Customer.where(:baan_id => baan_raw_data.attributes["baan_6"]).first.try(:id))
      purchase_order_attributes.merge!(:shipping_route_id => ShippingRoute.find_or_create_by_name(:name => baan_raw_data.attributes["baan_21"], :active => true).id)
      purchase_order_attributes.merge!(:warehouse_number => baan_raw_data.attributes["baan_22"])
      purchase_order_attributes.merge!(:level_2 => Address.where(:code => baan_raw_data.attributes["baan_47"], :category_id => 9).first.try(:id))
      purchase_order_attributes.merge!(:level_1 => Address.where(:code => baan_raw_data.attributes["baan_55"], :category_id => 8).first.try(:id))
      purchase_order_attributes.merge!(:level_3 => Address.where(:code => baan_raw_data.attributes["baan_71"], :category_id => 10).first.try(:id))
      purchase_order_attributes.merge!(:address_id => Address.where(:code => baan_raw_data.attributes["baan_71"]).first.try(:id))
      purchase_order_attributes.merge!(:category_id => Category.find_or_create_by_title_and_categorizable_type(:title => baan_raw_data.attributes["baan_81"], :categorizable_type => "purchase_order").id)
      
      # Set Error ShippingRoute if there is no shipping_route_id assigned to this purchase_order
      purchase_order_attributes[:shipping_route_id] = ShippingRoute.where(:name => "ERROR").first.id unless purchase_order_attributes[:shipping_route_id].present?
      
      purchase_order = PurchaseOrder.find_or_initialize_by_baan_id(purchase_order_attributes)
      if purchase_order.new_record?
        purchase_order.save
      else
        purchase_order_attributes.merge!(:id => purchase_order.id)
        unless PurchaseOrder.select(purchase_order_attributes.keys).where(:id => purchase_order.id).first.attributes == purchase_order_attributes
          # update logic comes here...
          purchase_order_attributes.delete(:id)
          purchase_order.update_attributes(purchase_order_attributes)
        end
      end
      purchase_order.addresses += Address.where(:id => [purchase_order_attributes[:level_1], purchase_order_attributes[:level_2], purchase_order_attributes[:level_3]])
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
  
  private
  
  def handle_calculation
    self.create_calculation unless self.calculation.present?
  end
  
end
