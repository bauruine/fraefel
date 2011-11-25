class Article < ActiveRecord::Base
  belongs_to :depot, :class_name => "Depot", :foreign_key => "depot_id"
  
  def self.import(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      baan_acces_id = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      article_code = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      depot_code = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      depot = Depot.where(:code => depot_code).first
      article_type = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.chomp.lstrip.rstrip
      signal_code_description = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip
      description = Iconv.conv('UTF-8', 'iso-8859-1', row[5]).to_s.chomp.lstrip.rstrip
      search_key_01 = Iconv.conv('UTF-8', 'iso-8859-1', row[6]).to_s.chomp.lstrip.rstrip
      search_key_02 = Iconv.conv('UTF-8', 'iso-8859-1', row[7]).to_s.chomp.lstrip.rstrip
      material = Iconv.conv('UTF-8', 'iso-8859-1', row[8]).to_s.chomp.lstrip.rstrip
      factor = Iconv.conv('UTF-8', 'iso-8859-1', row[9]).to_s.chomp.lstrip.rstrip
      zone_code = Iconv.conv('UTF-8', 'iso-8859-1', row[10]).to_s.chomp.lstrip.rstrip
      stock_unit = Iconv.conv('UTF-8', 'iso-8859-1', row[11]).to_s.chomp.lstrip.rstrip
      order_unit = Iconv.conv('UTF-8', 'iso-8859-1', row[12]).to_s.chomp.lstrip.rstrip
      trade_partner_name = Iconv.conv('UTF-8', 'iso-8859-1', row[13]).to_s.chomp.lstrip.rstrip
      trade_partner_additional_info = Iconv.conv('UTF-8', 'iso-8859-1', row[14]).to_s.chomp.lstrip.rstrip
    
      article = Article.find_or_initialize_by_baan_acces_id(:baan_acces_id => baan_acces_id)
      if article.present? && article.new_record?
        article.baan_acces_id = baan_acces_id
        article.article_code = article_code
        article.depot = depot
        article.signal_code_description = signal_code_description
        article.description = description
        article.search_key_01 = search_key_01
        article.search_key_02 = search_key_02
        article.material = material
        article.factor = factor
        article.zone_code = zone_code
        article.stock_unit = stock_unit
        article.order_unit = order_unit
        article.trade_partner_name = trade_partner_name
        article.trade_partner_additional_info = trade_partner_additional_info
        article.save
      else
        article.update_attributes(:baan_acces_id => baan_acces_id,
                                  :article_code => article_code,
                                  :depot => depot,
                                  :signal_code_description => signal_code_description,
                                  :description => description,
                                  :search_key_01 => search_key_01,
                                  :search_key_02 => search_key_02,
                                  :material => material,
                                  :factor => factor,
                                  :zone_code => zone_code,
                                  :stock_unit => stock_unit,
                                  :order_unit => order_unit,
                                  :trade_partner_name => trade_partner_name,
                                  :trade_partner_additional_info => trade_partner_additional_info)
      end
    end
  end
  
  def self.import_extras(arg)
    @baan_import = arg
    #PaperTrail.whodunnit = 'System'
    
    csv_file = @baan_import.baan_upload.path
    
    CSV.foreach(csv_file, {:col_sep => ";", :headers => :first_row}) do |row|
      
      baan_acces_id = Iconv.conv('UTF-8', 'iso-8859-1', row[0]).to_s.chomp.lstrip.rstrip
      rack_group_number = Iconv.conv('UTF-8', 'iso-8859-1', row[1]).to_s.chomp.lstrip.rstrip
      rack_root_number = Iconv.conv('UTF-8', 'iso-8859-1', row[2]).to_s.chomp.lstrip.rstrip
      rack_part_number = Iconv.conv('UTF-8', 'iso-8859-1', row[3]).to_s.chomp.lstrip.rstrip
      rack_tray_number = Iconv.conv('UTF-8', 'iso-8859-1', row[4]).to_s.chomp.lstrip.rstrip
      rack_box_number = Iconv.conv('UTF-8', 'iso-8859-1', row[5]).to_s.chomp.lstrip.rstrip
    
      article = Article.find_or_initialize_by_baan_acces_id(:baan_acces_id => baan_acces_id)
      if article.present?
        article.update_attributes(:rack_group_number => rack_group_number,
                                  :rack_root_number => rack_root_number,
                                  :rack_part_number => rack_part_number,
                                  :rack_tray_number => rack_tray_number,
                                  :rack_box_number => rack_box_number)
      end
    end
  end
  
end
