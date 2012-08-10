class PurchasePosition < ActiveRecord::Base
  belongs_to :commodity_code, :class_name => "CommodityCode", :foreign_key => "commodity_code_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :old_pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  belongs_to :zip_location, :class_name => "ZipLocation", :foreign_key => "zip_location_id"
  belongs_to :shipping_address, :class_name => "Address", :foreign_key => "level_3"
  belongs_to :shipping_route, :class_name => "ShippingRoute", :foreign_key => "shipping_route_id"
  
  has_many :pallet_purchase_position_assignments, :class_name => "PalletPurchasePositionAssignment"
  has_many :pallets, :class_name => "Pallet", :through => :pallet_purchase_position_assignments
  
  has_many :transport_issues
  has_many :delivery_rejections, :through => :transport_issues
  
  has_many :purchase_position_time_shifting_assignments
  has_many :time_shiftings, :class_name => "TimeShifting", :through => :purchase_position_time_shifting_assignments
  
  has_many :delivery_dates, :as => :dateable

  
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
  
  def self.create_from_raw_data(arg)
    commodity_code_id = CommodityCode.where(:code => arg.attributes["baan_0"]).first.try(:id)
    purchase_order = PurchaseOrder.where(:baan_id => arg.attributes["baan_2"])
    purchase_order_id = purchase_order.first.try(:id)
    level_3 = Address.where(:code => arg.attributes["baan_71"], :category_id => 10).first.try(:id)
    zip_location_id = ZipLocation.where(:title => arg.attributes["baan_35"]).first.try(:id)
    shipping_route_id = ShippingRoute.where(:name => arg.attributes["baan_21"]).first.try(:id)
    
    purchase_position_attributes = {}
    purchase_position_attributes.merge!(:commodity_code_id => commodity_code_id)
    purchase_position_attributes.merge!(:purchase_order_id => purchase_order_id)
    purchase_position_attributes.merge!(:baan_id => "#{arg.attributes["baan_2"]}-#{arg.attributes["baan_4"]}")
    purchase_position_attributes.merge!(:position => arg.attributes["baan_4"].to_i)
    purchase_position_attributes.merge!(:delivery_date => arg.attributes["baan_13"])
    purchase_position_attributes.merge!(:weight_single => arg.attributes["baan_15"].to_f)
    purchase_position_attributes.merge!(:weight_total => arg.attributes["baan_16"].to_f)
    purchase_position_attributes.merge!(:amount => arg.attributes["baan_17"].to_f)
    purchase_position_attributes.merge!(:quantity => arg.attributes["baan_18"].to_f)
    purchase_position_attributes.merge!(:storage_location => arg.attributes["baan_23"])
    purchase_position_attributes.merge!(:article_number => arg.attributes["baan_27"])
    purchase_position_attributes.merge!(:article => arg.attributes["baan_28"])
    purchase_position_attributes.merge!(:product_line => arg.attributes["baan_30"])
    purchase_position_attributes.merge!(:level_3 => level_3)
    purchase_position_attributes.merge!(:shipping_route_id => shipping_route_id)
    purchase_position_attributes.merge!(:zip_location_id => zip_location_id)
    purchase_position_attributes.merge!(:gross_price => arg.attributes["baan_38"])
    purchase_position_attributes.merge!(:value_discount => arg.attributes["baan_39"])
    purchase_position_attributes.merge!(:net_price => arg.attributes["baan_40"])
    purchase_position_attributes.merge!(:stock_status => arg.attributes["baan_78"].to_i)
    purchase_position_attributes.merge!(:production_status => arg.attributes["baan_79"].to_i)
    purchase_position_attributes.merge!(:picked_up => arg.attributes["baan_84"])
    
    # Set Error ShippingRoute if there is no shipping_route_id assigned to this purchase_position
    purchase_position_attributes[:shipping_route_id] = ShippingRoute.where(:name => "ERROR").first.id unless purchase_position_attributes[:shipping_route_id].present?
    
    purchase_position = PurchasePosition.find_or_initialize_by_position_and_purchase_order_id(purchase_position_attributes)
    if purchase_position.new_record?
      purchase_position.save
      purchase_position.delivery_dates.create(:date_of_delivery => purchase_position.delivery_date)
      if purchase_order.first.delivered
        purchase_order.first.update_attribute("delivered", false)
      end
    else
      update_entry = false
      purchase_position_attributes.merge!(:id => purchase_position.id)
      
      purchase_position_attributes.each do |k, v|
        if purchase_position.attributes[k] != v
          update_entry = true
        end
      end
      
      if update_entry
        purchase_position_attributes.delete(:id)
        purchase_position.update_attributes(purchase_position_attributes)
        if purchase_position.delivery_date != purchase_position.delivery_dates.last.try(:date_of_delivery)
          purchase_position.delivery_dates.create(:date_of_delivery => purchase_position.delivery_date)
        end
      end
    end
    
    if purchase_order.present?
      if purchase_order.first.purchase_positions.collect(&:picked_up).count {|x| x == true} == purchase_order.first.purchase_positions.collect(&:picked_up).size
        purchase_order.first.update_attribute("picked_up", true)
      end
      purchase_order.first.patch_calculation
      purchase_order.first.patch_aggregations
    end
    
  end
  
  protected
    
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    ag = Time.now
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      purchase_position_attributes = {}
      
      purchase_position_attributes.merge!(:commodity_code_id => CommodityCode.find_or_create_by_code(:code => baan_raw_data.attributes["baan_0"], :content => baan_raw_data.attributes["baan_1"]).id)
      purchase_position_attributes.merge!(:purchase_order_id => PurchaseOrder.where(:baan_id => baan_raw_data.attributes["baan_2"]).first.try(:id))
      purchase_position_attributes.merge!(:baan_id => "#{baan_raw_data.attributes["baan_2"]}-#{baan_raw_data.attributes["baan_4"]}")
      purchase_position_attributes.merge!(:position => baan_raw_data.attributes["baan_4"].to_i)
      purchase_position_attributes.merge!(:delivery_date => baan_raw_data.attributes["baan_13"])
      purchase_position_attributes.merge!(:weight_single => baan_raw_data.attributes["baan_15"].to_f)
      purchase_position_attributes.merge!(:weight_total => baan_raw_data.attributes["baan_16"].to_f)
      purchase_position_attributes.merge!(:amount => baan_raw_data.attributes["baan_17"].to_f)
      purchase_position_attributes.merge!(:quantity => baan_raw_data.attributes["baan_18"].to_f)
      purchase_position_attributes.merge!(:storage_location => baan_raw_data.attributes["baan_23"])
      purchase_position_attributes.merge!(:article_number => baan_raw_data.attributes["baan_27"])
      purchase_position_attributes.merge!(:article => baan_raw_data.attributes["baan_28"])
      purchase_position_attributes.merge!(:product_line => baan_raw_data.attributes["baan_30"])
      purchase_position_attributes.merge!(:level_3 => Address.where(:code => baan_raw_data.attributes["baan_71"], :category_id => 10).first.try(:id))
      
      
      purchase_position_attributes.merge!(:zip_location_id => ZipLocation.find_or_create_by_title(:title => baan_raw_data.attributes["baan_35"]).id)
      purchase_position_attributes.merge!(:gross_price => baan_raw_data.attributes["baan_38"])
      purchase_position_attributes.merge!(:value_discount => baan_raw_data.attributes["baan_39"])
      purchase_position_attributes.merge!(:net_price => baan_raw_data.attributes["baan_40"])
      purchase_position_attributes.merge!(:stock_status => baan_raw_data.attributes["baan_78"].to_i)
      purchase_position_attributes.merge!(:production_status => baan_raw_data.attributes["baan_79"].to_i)
      purchase_position_attributes.merge!(:picked_up => baan_raw_data.attributes["baan_84"])
      
      purchase_position = PurchasePosition.find_or_initialize_by_position_and_purchase_order_id(purchase_position_attributes)
      if purchase_position.new_record?
        purchase_position.save
        purchase_position.delivery_dates.create(:date_of_delivery => purchase_position.delivery_date)
        if purchase_position.purchase_order.delivered
          purchase_position.purchase_order.update_attribute("delivered", false)
        end
      else
        purchase_position_attributes.merge!(:id => purchase_position.id)
        unless PurchasePosition.select(purchase_position_attributes.keys).where(:id => purchase_position.id).first.attributes == purchase_position_attributes
          # update logic comes here...
          purchase_position_attributes.delete(:id)
          purchase_position.update_attributes(purchase_position_attributes)
          if purchase_position.delivery_date != purchase_position.delivery_dates.last.try(:date_of_delivery)
            purchase_position.delivery_dates.create(:date_of_delivery => purchase_position.delivery_date)
          end
        end
      end
      # Set picked_up true on purchase_order if children are picked_up
      if purchase_position.purchase_order.present?
        if purchase_position.purchase_order.purchase_positions.collect(&:picked_up).count {|x| x == true} == purchase_position.purchase_order.purchase_positions.collect(&:picked_up).size
          purchase_position.purchase_order.update_attribute("picked_up", true)
        end
      end
    end
    ab = Time.now
    puts (ab - ag).to_s
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
