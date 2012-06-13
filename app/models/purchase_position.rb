class PurchasePosition < ActiveRecord::Base
  belongs_to :commodity_code, :class_name => "CommodityCode", :foreign_key => "commodity_code_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :old_pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  
  has_many :pallet_purchase_position_assignments, :class_name => "PalletPurchasePositionAssignment"
  has_many :pallets, :class_name => "Pallet", :through => :pallet_purchase_position_assignments
  
  has_many :transport_issues
  has_many :delivery_rejections, :through => :transport_issues
  
  has_many :purchase_position_time_shifting_assignments
  has_many :time_shiftings, :class_name => "TimeShifting", :through => :purchase_position_time_shifting_assignments
  
  has_many :delivery_dates, :as => :dateable
  
  after_save :update_purchase_order_date
  
  scope :to_be_checked, where("amount = 0 OR weight_single = 0 OR quantity = 0")
  
  # has_paper_trail
  
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
  
  protected
  
  def update_purchase_order_date
    @purchase_order = self.purchase_order
    @purchase_position = self
    if @purchase_order.present?
      if @purchase_order.time_shiftings.where(:closed => false).present? && @purchase_order.time_shiftings.where(:closed => false).where("lt_date IS NOT NULL").collect(&:lt_date).compact.present?
        @date_for_update = @purchase_order.time_shiftings.where(:closed => false).where("lt_date IS NOT NULL").collect(&:lt_date).last
      else
        @date_for_update = @purchase_order.purchase_positions.order("delivery_date asc").limit(1).first.delivery_date.to_date
      end
      @purchase_order.update_attributes(:delivery_date => @date_for_update)
    end
    @purchase_position_assignment = PalletPurchasePositionAssignment.where(:purchase_position_id => self.id)
    if @purchase_position_assignment.present?
      @purchase_position_assignment.each do |p_p_p_a|
        p_p_p_a.update_attributes(:value_discount => ((@purchase_position.value_discount.present? ? @purchase_position.value_discount : 0) * p_p_p_a.quantity), :net_price => ((@purchase_position.net_price.present? ? @purchase_position.net_price : 0) * p_p_p_a.quantity), :gross_price => ((@purchase_position.gross_price.present? ? @purchase_position.gross_price : 0) * p_p_p_a.quantity), :amount => ((@purchase_position.amount.present? ? @purchase_position.amount : 0) * p_p_p_a.quantity), :weight => ((@purchase_position.weight_single.present? ? @purchase_position.weight_single : 0) * p_p_p_a.quantity))
      end
    end
  end
  
  def self.calculate_for_invoice(type, attrs)
    if attrs[1].present?
      sum("#{type}", :include => [:commodity_code, {:pallets => :cargo_list}], :conditions => {:cargo_lists => { :id => attrs[0] }, :commodity_codes => { :id => attrs[1] }})
    else
      sum("#{type}", :include => [:pallets => :cargo_list], :conditions => {:cargo_lists => { :id => attrs[0] }})
    end
  end
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    
    ag = Time.now
    BaanRawData.where(:baan_import_id => arg).each do |baan_raw_data|
      purchase_position_attributes = {}
      
      purchase_position_attributes.merge!(:status => "open")
      purchase_position_attributes.merge!(:commodity_code_id => CommodityCode.where(:code => baan_raw_data.attributes["baan_0"]).first.try(:id))
      purchase_position_attributes.merge!(:purchase_order_id => PurchaseOrder.where(:baan_id => baan_raw_data.attributes["baan_2"]).first.try(:id))
      purchase_position_attributes.merge!(:baan_id => "#{PurchaseOrder.where(:baan_id => baan_raw_data.attributes["baan_2"]).first.try(:baan_id)}-#{baan_raw_data.attributes["baan_4"]}")
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
      purchase_position_attributes.merge!(:consignee_full => baan_raw_data.attributes["baan_33"])
      purchase_position_attributes.merge!(:zip_location_id => baan_raw_data.attributes["baan_34"])
      purchase_position_attributes.merge!(:zip_location_name => baan_raw_data.attributes["baan_35"])
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
