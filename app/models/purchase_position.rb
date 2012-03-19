class PurchasePosition < ActiveRecord::Base
  belongs_to :commodity_code, :class_name => "CommodityCode", :foreign_key => "commodity_code_id"
  belongs_to :purchase_order, :class_name => "PurchaseOrder", :foreign_key => "purchase_order_id"
  belongs_to :old_pallet, :class_name => "Pallet", :foreign_key => "pallet_id"
  
  has_many :pallet_purchase_position_assignments, :class_name => "PalletPurchasePositionAssignment"
  has_many :pallets, :class_name => "Pallet", :through => :pallet_purchase_position_assignments
  
  has_many :transport_issues
  has_many :delivery_rejections, :through => :transport_issues
  
  after_save :update_purchase_order_date
  
  scope :to_be_checked, where("amount = 0 OR weight_single = 0 OR quantity = 0")
  
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
      @date_for_update = @purchase_order.purchase_positions.order("delivery_date asc").limit(1).first.delivery_date.to_date
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
    @baan_import = arg
    PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      baan_id = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      commodity_code = CommodityCode.find_by_code(Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip)
      purchase_order = PurchaseOrder.find_by_baan_id(baan_id)
      weight_single = Iconv.conv('UTF-8', 'iso-8859-1', row[15]).to_s.chomp.lstrip.rstrip.to_f
      weight_total = Iconv.conv('UTF-8', 'iso-8859-1', row[16]).to_s.chomp.lstrip.rstrip.to_f
      quantity = Iconv.conv('UTF-8', 'iso-8859-1', row[18]).to_s.chomp.lstrip.rstrip.to_f
      amount = Iconv.conv('UTF-8', 'iso-8859-1', row[17]).to_s.chomp.lstrip.rstrip.to_f
      position = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip.to_i
      delivery_date = Iconv.conv('UTF-8', 'iso-8859-1', row[13]).to_s.chomp.lstrip.rstrip
      article = Iconv.conv('UTF-8', 'iso-8859-1', row[28]).to_s.chomp.lstrip.rstrip
      article_number = Iconv.conv('UTF-8', 'iso-8859-1', row[27]).to_s.chomp.lstrip.rstrip
      product_line = Iconv.conv('UTF-8', 'iso-8859-1', row[30]).to_s.chomp.lstrip.rstrip
      storage_location = Iconv.conv('UTF-8', 'iso-8859-1', row[23]).to_s.chomp.lstrip.rstrip
      consignee_full = Iconv.conv('UTF-8', 'iso-8859-1', row[33]).to_s.chomp.lstrip.rstrip
      zip_location_id = Iconv.conv('UTF-8', 'iso-8859-1', row[34]).to_s.chomp.lstrip.rstrip
      zip_location_name = Iconv.conv('UTF-8', 'iso-8859-1', row[35]).to_s.chomp.lstrip.rstrip
      gross_price = row[38].to_s.undress
      value_discount = row[39].to_s.undress
      net_price = row[40].to_s.undress
      
      if !consignee_full.present?
        puts "Warning -- No consignee in CSV"
      end
      calculated_amount = amount * quantity
      if purchase_order.purchase_positions.where(:position => position).present?
        purchase_position = purchase_order.purchase_positions.where(:position => position).first
        csv_array = [weight_single.to_s, weight_total.to_s, quantity.to_s, amount.to_s, position, delivery_date]
        purchase_position_array = [purchase_position.weight_single.to_s, purchase_position.weight_total.to_s, purchase_position.quantity.to_s, purchase_position.amount.to_s, purchase_position.position, purchase_position.delivery_date]
        if (csv_array != purchase_position_array && purchase_position.status == "open")
          if purchase_position.pallets.present?
            purchase_position.update_attributes(:gross_price => gross_price, :value_discount => value_discount, :net_price => net_price, :article => article, :delivery_date => delivery_date, :product_line => product_line, :storage_location => storage_location, :article_number => article_number, :consignee_full => consignee_full, :zip_location_id => zip_location_id, :zip_location_name => zip_location_name)
            #puts purchase_position.consignee_full
          else
            purchase_position.update_attributes(:gross_price => gross_price, :value_discount => value_discount, :net_price => net_price, :commodity_code => commodity_code, :weight_single => weight_single, :weight_total => weight_total, :quantity => quantity, :amount => amount, :position => position, :status => "open", :article => article, :delivery_date => delivery_date, :product_line => product_line, :storage_location => storage_location, :article_number => article_number, :total_amount => calculated_amount, :consignee_full => consignee_full, :zip_location_id => zip_location_id, :zip_location_name => zip_location_name)
            #puts purchase_position.consignee_full
          end
        else
        end
        purchase_position.update_attributes(:consignee_full => consignee_full)
      else
        purchase_position = purchase_order.purchase_positions.build(:gross_price => gross_price, :value_discount => value_discount, :net_price => net_price, :commodity_code => commodity_code, :weight_single => weight_single, :weight_total => weight_total, :quantity => quantity, :amount => amount, :position => position, :status => "open", :delivery_date => delivery_date, :article => article, :product_line => product_line, :storage_location => storage_location, :article_number => article_number, :total_amount => calculated_amount, :consignee_full => consignee_full, :zip_location_id => zip_location_id, :zip_location_name => zip_location_name)
        if purchase_position.save
          #puts purchase_position.consignee_full
          #puts "New Purchase Position has been created: #{purchase_position.attributes}"
        else
          puts "ERROR-- PurchasePosition not saved..."
        end
      end
    end
    
  end
  
end
