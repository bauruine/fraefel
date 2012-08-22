class BaanRawData < ActiveRecord::Base
  belongs_to :baan_import, :class_name => "BaanImport", :foreign_key => "baan_import_id"
  
  after_create :create_import_purchase_order
  after_create :create_import_purchase_position
  after_create :create_import_address
  after_create :create_import_customer
  after_create :create_import_shipping_route
  after_create :create_import_zip_location
  after_create :create_import_commodity_code
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    csv_file_path = @baan_import.baan_upload.path
    
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    ag = Time.now

    csv_file.each do |row|
      @baan_raw_attributes = {}
      # added new lines 82 83 84
      for i in 0..84 do
        @baan_raw_attributes.merge!("baan_#{i}".to_sym => row[i].to_s.undress)
      end
      @baan_raw_attributes.merge!(:baan_import_id => @baan_import.id)
      BaanRawData.find_or_create_by_baan_2_and_baan_4_and_baan_import_id(@baan_raw_attributes)
    end
    
    ab = Time.now
    puts (ab - ag).to_s
  end
  
  def self.patch_import(arg)
    @baan_import = BaanImport.find(arg)
    BaanRawData.where(:baan_import_id => @baan_import.id).group(:baan_2).count.each do |b_r_d|
      @p_o = PurchaseOrder.where(:baan_id => b_r_d.first)
      if @p_o.present?
        PurchaseOrder.patch_calculation(@p_o.first.baan_id)
        PurchaseOrder.patch_aggregations(@p_o.first.baan_id)
      end
    end
  end
  
  def self.import_cancelled(arg)
    @baan_import = BaanImport.find(arg)
    csv_file_path = @baan_import.baan_upload.path
    
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})
    ag = Time.now

    csv_file.each do |row|
      BaanRawData.find_or_create_by_baan_2_and_baan_4_and_baan_import_id(:baan_2 => row[1].to_s.undress, :baan_4 => row[2].to_s.undress, :baan_import_id => @baan_import.id)
      @purchase_position = PurchasePosition.where(:baan_id => "#{row[1].to_s.undress}-#{row[2].to_s.undress}").first
      if @purchase_position.present?
        @purchase_position.update_attribute("cancelled", row[0].to_s.undress)
      end
    end
    @baan_raw_data = BaanRawData.where(:baan_import_id => @baan_import.id)
    
    PurchaseOrder.where(:baan_id => @baan_raw_data.collect(&:baan_2)).each do |purchase_order|
      if PurchasePosition.where(:purchase_order_id => purchase_order.id).count == PurchasePosition.where(:purchase_order_id => purchase_order.id, "purchase_positions.cancelled" => true).count
        purchase_order.update_attribute("cancelled", true)
      end
      purchase_order.patch_calculation
      purchase_order.patch_aggregations
    end
    
    ab = Time.now
    puts (ab - ag).to_s
  end
  
  protected
  
  def create_import_purchase_order
    unless Import::PurchaseOrder.find(:baan_id => self.baan_2).present?
      Import::PurchaseOrder.create(:baan_id => self.baan_2)
    end
  end
  
  def create_import_purchase_position
    unless Import::PurchasePosition.find(:baan_id => "#{self.baan_2}-#{self.baan_4}").present?
      Import::PurchasePosition.create(:baan_id => "#{self.baan_2}-#{self.baan_4}")
    end
  end
  
  def create_import_address
    begin
      Import::Address.create(:baan_id => self.baan_55, :category_id => "8", :unique_id => Digest::MD5.hexdigest("#{self.baan_55}-8"))
      Import::Address.create(:baan_id => self.baan_47, :category_id => "9", :unique_id => Digest::MD5.hexdigest("#{self.baan_47}-9"))
      Import::Address.create(:baan_id => self.baan_71, :category_id => "10", :unique_id => Digest::MD5.hexdigest("#{self.baan_71}-10"))
    rescue Ohm::UniqueIndexViolation
      "Skipping address..."
    end
  end
  
  def create_import_customer
    unless Import::Customer.find(:baan_id => self.baan_6).present?
      Import::Customer.create(:baan_id => self.baan_6)
    end
  end
  
  def create_import_shipping_route
    unless Import::ShippingRoute.find(:baan_id => self.baan_21).present?
      Import::ShippingRoute.create(:baan_id => self.baan_21)
    end
  end
  
  def create_import_zip_location
    unless Import::ZipLocation.find(:baan_id => self.baan_35).present?
      Import::ZipLocation.create(:baan_id => self.baan_35)
    end
  end
  
  def create_import_commodity_code
    unless Import::CommodityCode.find(:baan_id => self.baan_0).present?
      Import::CommodityCode.create(:baan_id => self.baan_0)
    end
  end
  
end
