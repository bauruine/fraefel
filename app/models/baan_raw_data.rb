class BaanRawData < ActiveRecord::Base
  belongs_to :baan_import, :class_name => "BaanImport", :foreign_key => "baan_import_id"
  
  def self.import(arg)
    @baan_import = BaanImport.find(arg)
    csv_file_path = @baan_import.baan_upload.path
    
    csv_file = CSV.open(csv_file_path, {:col_sep => ";", :headers => :first_row})
    ag = Time.now

    csv_file.each do |row|
      @baan_raw_attributes = {}
      for i in 0..81 do
        @baan_raw_attributes.merge!("baan_#{i}".to_sym => row[i].to_s.undress)
        @baan_raw_attributes.merge!(:baan_import_id => @baan_import.id)
      end
      BaanRawData.find_or_create_by_baan_2_and_baan_4(@baan_raw_attributes)
    end
    ab = Time.now
    puts (ab - ag).to_s
  end
end
