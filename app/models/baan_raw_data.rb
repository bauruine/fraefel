class BaanRawData < ActiveRecord::Base
  belongs_to :baan_import, :class_name => "BaanImport", :foreign_key => "baan_import_id"
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    csv_file_path = @baan_import.baan_upload.path
    
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
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
end
