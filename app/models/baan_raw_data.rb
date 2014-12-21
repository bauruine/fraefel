class BaanRawData < ActiveRecord::Base
  attr_accessor :should_preload

  belongs_to :baan_import, :class_name => "BaanImport", :foreign_key => "baan_import_id"

  after_create :create_import_purchase_order, :if => :should_preload
  after_create :create_import_purchase_position, :if => :should_preload
  after_create :create_import_address, :if => :should_preload
  after_create :create_import_customer, :if => :should_preload
  after_create :create_import_shipping_route, :if => :should_preload
  after_create :create_import_zip_location, :if => :should_preload
  after_create :create_import_commodity_code, :if => :should_preload
  after_create :create_import_category, :if => :should_preload

  def self.import(arg, preloading = true)
    @baan_import = BaanImport.find(arg)
    preloading = preloading
    csv_file_path = @baan_import.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})

    csv_file.each do |row|
      @baan_raw_attributes = {}
      # added new lines 82 83 84
      for i in 0..87 do
        @baan_raw_attributes.merge!("baan_#{i}".to_sym => row[i].to_s.undress)
      end
      @baan_raw_attributes.merge!(:baan_import_id => @baan_import.id)
      unless BaanRawData.where(:baan_import_id => @baan_import.id, :baan_2 => @baan_raw_attributes[:baan_2], :baan_4 => @baan_raw_attributes[:baan_4]).present?
        baan_raw_data = BaanRawData.new(@baan_raw_attributes)
        baan_raw_data.should_preload = preloading
        baan_raw_data.save
      end
    end

  end

  def self.import_cancelled(arg)
    @baan_import = BaanImport.find(arg)
    csv_file_path = @baan_import.baan_upload.path
    csv_file = CSV.open(csv_file_path, "rb:iso-8859-1:UTF-8", {:col_sep => ";", :headers => :first_row})

    csv_file.each do |row|
      BaanRawData.find_or_create_by_baan_2_and_baan_4_and_baan_import_id(:baan_2 => row[1].to_s.undress, :baan_4 => row[2].to_s.undress, :baan_import_id => @baan_import.id)
    end
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
    unless Import::Address.find(:unique_id => Digest::MD5.hexdigest("#{self.baan_55}-8")).present?
      Import::Address.create(:baan_id => self.baan_55, :category_id => "8", :unique_id => Digest::MD5.hexdigest("#{self.baan_55}-8"))
    end
    unless Import::Address.find(:unique_id => Digest::MD5.hexdigest("#{self.baan_47}-9")).present?
      Import::Address.create(:baan_id => self.baan_47, :category_id => "9", :unique_id => Digest::MD5.hexdigest("#{self.baan_47}-9"))
    end
    unless Import::Address.find(:unique_id => Digest::MD5.hexdigest("#{self.baan_71}-10")).present?
      Import::Address.create(:baan_id => self.baan_71, :category_id => "10", :unique_id => Digest::MD5.hexdigest("#{self.baan_71}-10"))
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

  def create_import_category
    unless Import::Category.find(:unique_id => Digest::MD5.hexdigest(%Q(#{self.baan_81}-purchase_order))).present?
      Import::Category.create(:baan_id => self.baan_81, :categorizable_type => "purchase_order", :unique_id => Digest::MD5.hexdigest(%Q(#{self.baan_81}-purchase_order)))
    end
  end

end
